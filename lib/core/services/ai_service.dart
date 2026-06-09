import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  static const String _apiKeyPrefsKey = 'gemini_api_key_todoapp';
  static bool _hasRunDiagnostics = false;

  static const List<String> _modelCandidates = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-3.5-flash',
    'gemini-flash-latest',
    'gemini-2.5-pro',
    'gemini-1.5-flash',
  ];

  /// Lưu API Key vào SharedPreferences
  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefsKey, key.trim());
    _hasRunDiagnostics = false; // Reset chẩn đoán khi đổi key mới
  }

  /// Lấy API Key từ SharedPreferences
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_apiKeyPrefsKey);
    return (key != null && key.trim().isNotEmpty) ? key.trim() : null;
  }

  /// Xóa API Key
  Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPrefsKey);
  }

  /// Thực hiện chẩn đoán API Key và in ra lỗi chi tiết kèm danh sách model khả dụng
  Future<void> _runDiagnostics(String apiKey) async {
    print('🔍 AIService: Bắt đầu chẩn đoán API Key...');
    HttpClient? client;
    try {
      client = HttpClient();
      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 5));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('📊 AIService Diagnostics: HTTP Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseBody);
        final models = data['models'] as List<dynamic>?;
        if (models != null && models.isNotEmpty) {
          print('✅ API Key hợp lệ và hoạt động bình thường.');
          print('📋 Danh sách các models khả dụng với API Key này:');
          for (final model in models) {
            final String name = model['name'] ?? '';
            final List<dynamic> methods = model['supportedGenerationMethods'] ?? [];
            if (methods.contains('generateContent')) {
              print('   - $name (Hỗ trợ generateContent)');
            }
          }
        } else {
          print('⚠️ API Key hợp lệ nhưng không tìm thấy model nào hỗ trợ generateContent.');
        }
      } else {
        print('❌ Lỗi API Key! Chi tiết phản hồi từ Google API:');
        print('   Status Code: ${response.statusCode}');
        print('   Body: $responseBody');
        print('💡 Gợi ý xử lý:');
        if (responseBody.contains('API_KEY_INVALID') || responseBody.contains('not valid')) {
          print('   -> API Key không hợp lệ. Vui lòng kiểm tra lại xem đã sao chép đúng chưa.');
        } else if (responseBody.contains('API key expired')) {
          print('   -> API Key đã hết hạn. Hãy tạo một key mới.');
        } else if (responseBody.contains('Generative Language API') && responseBody.contains('details')) {
          print('   -> Bạn chưa kích hoạt "Generative Language API" trong Google Cloud Console cho dự án chứa API Key này.');
        } else {
          print('   -> Vui lòng truy cập https://aistudio.google.com/ để tạo một Gemini API Key mới miễn phí.');
        }
      }
    } catch (e) {
      print('❌ AIService Diagnostics: Không thể kết nối tới Google API để chẩn đoán: $e');
    } finally {
      client?.close();
    }
  }

  /// Tạo nội dung với cơ chế tự động thử lại bằng các model khác nhau nếu gặp lỗi
  Future<GenerateContentResponse> _generateWithFallback({
    required String apiKey,
    required String prompt,
    bool isJsonMode = false,
  }) async {
    Object? lastError;
    
    for (final modelName in _modelCandidates) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          generationConfig: isJsonMode
              ? GenerationConfig(responseMimeType: 'application/json')
              : null,
        );

        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);
        if (response.text != null) {
          print('✅ AIService: Gọi thành công bằng model: $modelName');
          return response;
        }
      } catch (e) {
        lastError = e;
        print('⚠️ AIService: Model $modelName gặp lỗi: $e. Thử model tiếp theo...');
      }
    }

    if (!_hasRunDiagnostics) {
      _hasRunDiagnostics = true;
      _runDiagnostics(apiKey);
    }

    throw lastError ?? Exception('Toàn bộ model ứng viên đều thất bại mà không rõ nguyên nhân');
  }

  /// Phân tách công việc con (Subtasks Breakdown)
  Future<List<String>> generateSubtasks(String taskTitle) async {
    final apiKey = await getApiKey();
    
    if (apiKey == null) {
      print('ℹ️ AIService: Không tìm thấy API Key, sử dụng local fallback.');
      return _getLocalFallbackSubtasks(taskTitle);
    }

    try {
      final prompt = '''
Phân tách công việc sau đây thành danh sách từ 3 đến 5 công việc con (subtasks) thực tế bằng Tiếng Việt.
Công việc chính: "$taskTitle"
Yêu cầu định dạng trả về chính xác là một JSON array chứa các chuỗi (list of strings). Mỗi công việc con nên ngắn gọn, từ 2 đến 6 từ.
Ví dụ định dạng trả về:
["Việc con 1", "Việc con 2", "Việc con 3"]
''';

      final response = await _generateWithFallback(
        apiKey: apiKey,
        prompt: prompt,
        isJsonMode: true,
      );
      
      if (response.text != null) {
        final List<dynamic> decoded = json.decode(response.text!);
        return decoded.map((e) => e.toString()).toList();
      }
      return _getLocalFallbackSubtasks(taskTitle);
    } catch (e) {
      print('❌ AIService: Thất bại phân tách công việc bằng AI: $e. Sử dụng local fallback.');
      return _getLocalFallbackSubtasks(taskTitle);
    }
  }

  /// Lời khuyên năng suất (AI Productivity Coach Advice)
  Future<String> getCoachAdvice({
    required int completed,
    required int pending,
    required int overdue,
    required int focusSeconds,
  }) async {
    final apiKey = await getApiKey();

    if (apiKey == null) {
      print('ℹ️ AIService: Không tìm thấy API Key, sử dụng local fallback cho lời khuyên.');
      return _getLocalFallbackAdvice(completed, pending, overdue, focusSeconds);
    }

    try {
      final double completionRate = (completed + pending) > 0 
          ? (completed / (completed + pending)) * 100 
          : 0.0;
      final int focusMinutes = focusSeconds ~/ 60;

      final prompt = '''
Hãy đóng vai là một huấn luyện viên năng suất (Productivity Coach) thông thái và thân thiện. 
Dưới đây là số liệu hiệu suất làm việc ngày hôm nay của tôi:
- Đã hoàn thành: $completed công việc
- Đang chờ xử lý: $pending công việc
- Đã quá hạn: $overdue công việc
- Tỉ lệ hoàn thành: ${completionRate.toStringAsFixed(0)}%
- Thời gian tập trung Pomodoro: $focusMinutes phút

Hãy đưa ra lời khuyên ngắn gọn (từ 2 đến 3 câu), thiết thực và truyền cảm hứng bằng Tiếng Việt để giúp tôi làm việc hiệu quả hơn hoặc ghi nhận nỗ lực của tôi. Xưng hô "Tôi" (Huấn luyện viên) và "Bạn" (Người dùng).
''';

      final response = await _generateWithFallback(
        apiKey: apiKey,
        prompt: prompt,
        isJsonMode: false,
      );
      return response.text?.trim() ?? _getLocalFallbackAdvice(completed, pending, overdue, focusSeconds);
    } catch (e) {
      print('❌ AIService: Thất bại lấy lời khuyên AI: $e. Sử dụng local fallback.');
      return _getLocalFallbackAdvice(completed, pending, overdue, focusSeconds);
    }
  }

  /// Fallback cục bộ tạo việc con
  List<String> _getLocalFallbackSubtasks(String title) {
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('học') || 
        lowerTitle.contains('thi') || 
        lowerTitle.contains('flutter') || 
        lowerTitle.contains('code') || 
        lowerTitle.contains('lập trình')) {
      return [
        'Đọc tài liệu hướng dẫn lý thuyết',
        'Viết mã nguồn thực hành dự án',
        'Sửa lỗi debug code phát sinh',
        'Kiểm tra lại kết quả chạy thử',
      ];
    }
    
    if (lowerTitle.contains('dọn') || 
        lowerTitle.contains('nhà') || 
        lowerTitle.contains('rửa') || 
        lowerTitle.contains('lau') || 
        lowerTitle.contains('quét')) {
      return [
        'Quét dọn sàn nhà sạch sẽ',
        'Lau bụi bẩn trên bàn ghế',
        'Sắp xếp gọn gàng đồ đạc',
        'Vứt rác thải đúng nơi quy định',
      ];
    }
    
    if (lowerTitle.contains('mua') || 
        lowerTitle.contains('sắm') || 
        lowerTitle.contains('siêu thị') || 
        lowerTitle.contains('chợ')) {
      return [
        'Lên danh sách món cần mua',
        'Đi đến cửa hàng hoặc siêu thị',
        'Thanh toán hóa đơn sản phẩm',
        'Sắp xếp đồ mua gọn vào tủ',
      ];
    }
    
    if (lowerTitle.contains('tập') || 
        lowerTitle.contains('gym') || 
        lowerTitle.contains('chạy') || 
        lowerTitle.contains('thể thao') || 
        lowerTitle.contains('sức khỏe')) {
      return [
        'Khởi động nhẹ cơ thể 5 phút',
        'Thực hiện các bài tập chính',
        'Uống nước bổ sung đầy đủ',
        'Giãn cơ thả lỏng sau khi tập',
      ];
    }

    // Fallback mặc định cho các công việc khác
    return [
      'Nghiên cứu kỹ yêu cầu công việc',
      'Chuẩn bị các công cụ cần thiết',
      'Tiến hành các bước làm chính',
      'Kiểm tra, nghiệm thu kết quả',
    ];
  }

  /// Fallback cục bộ tạo lời khuyên năng suất
  String _getLocalFallbackAdvice(int completed, int pending, int overdue, int focusSeconds) {
    final int focusMinutes = focusSeconds ~/ 60;
    
    if (overdue > 0) {
      return 'Bạn đang có $overdue công việc bị quá hạn. Hãy tập trung ưu tiên hoàn thành chúng trước, hoặc phân chia nhỏ công việc đó để dễ dàng thực hiện từng bước bạn nhé!';
    }
    
    if (focusMinutes >= 25) {
      return 'Tuyệt vời! Bạn đã có $focusMinutes phút tập trung Pomodoro sâu hôm nay. Sự kiên trì và kỷ luật này sẽ mang lại kết quả xứng đáng, hãy tiếp tục phát huy!';
    }
    
    if (completed > 0 && pending == 0) {
      return 'Xin chúc mừng! Bạn đã giải quyết sạch sẽ tất cả công việc đề ra hôm nay. Hãy dành thời gian nghỉ ngơi trọn vẹn và nạp lại năng lượng cho ngày mới nhé!';
    }

    if (completed > 0) {
      return 'Hôm nay bạn đã hoàn thành $completed công việc rất tốt! Hãy tiếp tục duy trì đà làm việc này cho các đầu việc còn lại bằng cách bật đồng hồ tập trung.';
    }

    return 'Để bắt đầu một ngày làm việc hiệu quả, hãy chọn ra 3 công việc quan trọng nhất hôm nay, lên lịch hạn chót rõ ràng và chia nhỏ các bước thực hiện nhé!';
  }
}
