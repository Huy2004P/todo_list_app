import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../application/bloc/task_bloc.dart';
import '../../application/bloc/task_event.dart';
import '../../application/bloc/list_bloc.dart';
import '../../application/bloc/list_state.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/entities/subtask_entity.dart';

class EditTodoPage extends StatefulWidget {
  final int id;
  final TodoEntity oldTodo;

  const EditTodoPage({super.key, required this.id, required this.oldTodo});

  @override
  State<StatefulWidget> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  final _formkey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subtaskController;
  late TextEditingController _tagController;

  late String _priority;
  late String _category;
  DateTime? _dueDate;
  late List<SubTaskEntity> _subtasks;
  late List<String> _tags;
  late List<String> _imagePaths;
  String? _audioPath;
  late String _recurrence;
  String? _selectedListId;

  // Media services state
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.oldTodo.title);
    _descController = TextEditingController(text: widget.oldTodo.description ?? '');
    _subtaskController = TextEditingController();
    _tagController = TextEditingController();
    
    _priority = widget.oldTodo.priority;
    _category = widget.oldTodo.category;
    _dueDate = widget.oldTodo.dueDate;
    _subtasks = List<SubTaskEntity>.from(widget.oldTodo.subtasks);
    _tags = List<String>.from(widget.oldTodo.tags);
    _imagePaths = List<String>.from(widget.oldTodo.imagePaths);
    _audioPath = widget.oldTodo.audioPath;
    _recurrence = widget.oldTodo.recurrence;
    _selectedListId = widget.oldTodo.listId;

    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();

    // Listen to audio player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskController.dispose();
    _tagController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getCategoryNameVi(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return 'Công việc';
      case 'personal':
        return 'Cá nhân';
      case 'education':
        return 'Học tập';
      case 'shopping':
        return 'Mua sắm';
      case 'others':
      default:
        return 'Khác';
    }
  }

  String _formatDateTime(DateTime dt) {
    final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$timeStr $dateStr';
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (!context.mounted) return;
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _dueDate != null
            ? TimeOfDay(hour: _dueDate!.hour, minute: _dueDate!.minute)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addSubtask() {
    final title = _subtaskController.text.trim();
    if (title.isNotEmpty) {
      setState(() {
        _subtasks.add(SubTaskEntity(
          id: '${DateTime.now().millisecondsSinceEpoch}_${_subtasks.length}',
          title: title,
          isDone: false,
        ));
        _subtaskController.clear();
      });
    }
  }

  void _addTag() {
    final tagText = _tagController.text.trim().replaceAll('#', '');
    if (tagText.isNotEmpty && !_tags.contains(tagText)) {
      setState(() {
        _tags.add(tagText);
        _tagController.clear();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _imagePaths.add(image.path);
        });
      }
    } catch (e) {
      print('Lỗi chọn hình ảnh: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = Directory.systemTemp;
        final path = '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _audioPath = path;
        });
      }
    } catch (e) {
      print('Lỗi bắt đầu ghi âm: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        if (path != null) {
          _audioPath = path;
        }
      });
    } catch (e) {
      print('Lỗi dừng ghi âm: $e');
    }
  }

  void _togglePlayback() async {
    if (_audioPath == null) return;
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      } else {
        await _audioPlayer.play(DeviceFileSource(_audioPath!));
      }
    } catch (e) {
      print('Lỗi phát âm thanh: $e');
    }
  }

  void _saveChanges() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final updated = widget.oldTodo.copyWith(
      title: title,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      priority: _priority,
      category: _category,
      dueDate: _dueDate,
      subtasks: _subtasks,
      tags: _tags,
      imagePaths: _imagePaths,
      audioPath: _audioPath,
      recurrence: _recurrence,
      listId: _selectedListId,
    );

    context.read<TaskBloc>().add(UpdateTaskEvent(updated));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final Color inkMuted = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF7A7A7A);
    final Color canvasColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chỉnh sửa', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: inkColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Chỉnh sửa công việc",
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.28,
                    color: inkColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Folder/List selector
                BlocBuilder<ListBloc, ListState>(
                  builder: (context, listState) {
                    if (listState is ListLoaded && listState.lists.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Thư mục công việc",
                            style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedListId,
                            hint: Text('Không thuộc thư mục nào', style: TextStyle(color: inkMuted, fontSize: 14)),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: canvasColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('Mặc định (Tất cả)', style: TextStyle(color: inkColor)),
                              ),
                              ...listState.lists.map((list) {
                                return DropdownMenuItem<String>(
                                  value: list.id,
                                  child: Row(
                                    children: [
                                      Icon(Icons.folder, color: Color(list.colorHex), size: 18),
                                      const SizedBox(width: 8),
                                      Text(list.name, style: TextStyle(color: inkColor)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedListId = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên công việc *',
                    hintText: 'Nhập việc cần làm...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên công việc';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Input
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Chi tiết mô tả',
                    hintText: 'Nhập mô tả thêm (không bắt buộc)...',
                  ),
                ),
                const SizedBox(height: 20),

                // Recurrence
                Text(
                  "Lặp lại",
                  style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _recurrence,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: canvasColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('Không lặp lại')),
                    DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                    DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                    DropdownMenuItem(value: 'monthly', child: Text('Hàng tháng')),
                    DropdownMenuItem(value: 'yearly', child: Text('Hàng năm')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _recurrence = val ?? 'none';
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Custom Tags
                Text(
                  "Nhãn thẻ (Tags)",
                  style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          hintText: 'Thêm thẻ (ví dụ: giadinh)...',
                          filled: true,
                          fillColor: canvasColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addTag,
                      icon: const Icon(Icons.add_circle, color: Color(0xFF0066CC), size: 32),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _tags.map((tag) {
                      return InputChip(
                        label: Text('#$tag'),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                        deleteIconColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),

                // Category Selection
                Text(
                  "Chọn Danh mục",
                  style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: ['Work', 'Personal', 'Education', 'Shopping', 'Others'].map((cat) {
                    return _buildConfiguratorOption(
                      context,
                      isSelected: _category == cat,
                      label: _getCategoryNameVi(cat),
                      onTap: () => setState(() => _category = cat),
                      isDark: isDark,
                      inkColor: inkColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Priority Selection
                Text(
                  "Chọn Độ ưu tiên",
                  style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildConfiguratorOption(
                        context,
                        isSelected: _priority == 'low',
                        label: 'Thấp',
                        onTap: () => setState(() => _priority = 'low'),
                        isDark: isDark,
                        inkColor: inkColor,
                        icon: const Icon(Icons.flag, size: 14, color: Color(0xFF0066CC)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildConfiguratorOption(
                        context,
                        isSelected: _priority == 'medium',
                        label: 'T.Bình',
                        onTap: () => setState(() => _priority = 'medium'),
                        isDark: isDark,
                        inkColor: inkColor,
                        icon: const Icon(Icons.flag, size: 14, color: Color(0xFFF59E0B)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildConfiguratorOption(
                        context,
                        isSelected: _priority == 'high',
                        label: 'Cao',
                        onTap: () => setState(() => _priority = 'high'),
                        isDark: isDark,
                        inkColor: inkColor,
                        icon: const Icon(Icons.flag, size: 14, color: Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Due Date
                Text(
                  "Thiết lập hạn chót",
                  style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: canvasColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          _dueDate == null ? 'Không có hạn chót' : _formatDateTime(_dueDate!),
                          style: TextStyle(fontFamily: 'SF Pro Text', fontSize: 14, color: _dueDate == null ? inkMuted : inkColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _selectDueDate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFFAFAFC),
                        foregroundColor: isDark ? Colors.white : const Color(0xFF333333),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                      child: const Text('Chọn'),
                    ),
                    if (_dueDate != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => setState(() => _dueDate = null),
                        icon: const Icon(Icons.clear, color: Colors.redAccent),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 20),

                // Image attachments
                Text(
                  "Đính kèm hình ảnh",
                  style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Máy ảnh'),
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), foregroundColor: inkColor),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Thư viện'),
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), foregroundColor: inkColor),
                    ),
                  ],
                ),
                if (_imagePaths.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imagePaths.length,
                      itemBuilder: (context, idx) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(_imagePaths[idx])),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imagePaths.removeAt(idx);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Audio recording notes
                Text(
                  "Ghi âm ghi chú",
                  style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: canvasColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.redAccent : const Color(0xFF0066CC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isRecording ? "Đang thu âm giọng nói..." : (_audioPath != null ? "Đã lưu bản ghi âm" : "Chưa có bản ghi âm"),
                              style: TextStyle(
                                fontFamily: 'SF Pro Text',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: _isRecording ? Colors.redAccent : inkColor,
                              ),
                            ),
                            if (!_isRecording && _audioPath != null)
                              Text(
                                "Nhấn nút Phát bên phải để nghe lại",
                                style: TextStyle(fontFamily: 'SF Pro Text', fontSize: 11, color: inkMuted),
                              )
                          ],
                        ),
                      ),
                      if (!_isRecording && _audioPath != null) ...[
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: const Color(0xFF0066CC)),
                          onPressed: _togglePlayback,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              _audioPath = null;
                            });
                          },
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Subtasks
                Text(
                  "Việc con (${_subtasks.length})",
                  style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 16, fontWeight: FontWeight.w600, color: inkColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        decoration: InputDecoration(
                          hintText: 'Thêm việc con...',
                          filled: true,
                          fillColor: canvasColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        onSubmitted: (_) => _addSubtask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addSubtask,
                      icon: const Icon(Icons.add_circle, color: Color(0xFF0066CC), size: 32),
                    ),
                  ],
                ),
                if (_subtasks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    color: canvasColor,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subtasks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final sub = _subtasks[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            sub.title,
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 15,
                              color: inkColor,
                              decoration: sub.isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => setState(() => _subtasks.removeAt(index)),
                            icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 40),

                // Save Button
                ElevatedButton(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      _saveChanges();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Lưu thay đổi',
                    style: TextStyle(fontFamily: 'SF Pro Text', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfiguratorOption(
    BuildContext context, {
    required bool isSelected,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required Color inkColor,
    Widget? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF272729) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0071E3) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF0071E3) : inkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
