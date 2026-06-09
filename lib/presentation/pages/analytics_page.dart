import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todoapp/application/bloc/task_bloc.dart';
import 'package:todoapp/application/bloc/task_event.dart';
import 'package:todoapp/application/bloc/task_state.dart';
import 'package:todoapp/domain/entities/todo_entity.dart';
import 'package:todoapp/core/services/ai_service.dart';
import 'package:todoapp/presentation/widgets/ai_settings_dialog.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  Future<void> _exportToCSV(BuildContext context, List<TodoEntity> todos) async {
    try {
      final StringBuffer csvContent = StringBuffer();
      // Write CSV headers (UTF-8 BOM for Excel Excel compatibility)
      csvContent.write('\uFEFF');
      csvContent.writeln('ID,Tiêu đề,Trạng thái,Độ ưu tiên,Thư mục/Danh mục,Thời gian tập trung (giây),Hạn chót,Ngày tạo');
      
      for (final todo in todos) {
        final status = todo.isDone ? 'Đã xong' : 'Đang làm';
        final priority = todo.priority == 'high' ? 'Cao' : (todo.priority == 'low' ? 'Thấp' : 'Trung bình');
        final dueDateStr = todo.dueDate != null ? todo.dueDate!.toIso8601String() : '';
        
        final escapedTitle = todo.title.contains(',') ? '"${todo.title}"' : todo.title;
        final escapedCategory = todo.category.contains(',') ? '"${todo.category}"' : todo.category;

        csvContent.writeln('${todo.id},$escapedTitle,$status,$priority,$escapedCategory,${todo.focusDurationSeconds},$dueDateStr,${todo.createdAt.toIso8601String()}');
      }

      final bytes = utf8.encode(csvContent.toString());
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/todo_report.csv');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Báo cáo hiệu suất công việc Todo App',
      );
    } catch (e) {
      print('❌ Lỗi xuất CSV: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xuất báo cáo thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final inkMuted = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF7A7A7A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Thống kê hiệu suất',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: inkColor, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.sparkles, color: inkColor, size: 20),
            tooltip: 'Cấu hình Gemini AI',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const AISettingsDialog(),
              ).then((value) {
                if (value == true && context.mounted) {
                  context.read<TaskBloc>().add(LoadTaskEvent());
                }
              });
            },
          ),
          IconButton(
            icon: Icon(CupertinoIcons.share, color: inkColor, size: 20),
            tooltip: 'Xuất CSV',
            onPressed: () {
              final taskState = context.read<TaskBloc>().state;
              if (taskState is TaskLoaded) {
                _exportToCSV(context, taskState.allTodos);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dữ liệu chưa sẵn sàng để xuất')),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoaded) {
            final activeTodos = state.allTodos.where((t) => !t.isTrash).toList();
            final total = activeTodos.length;
            final completed = activeTodos.where((t) => t.isDone).toList();
            final completedCount = completed.length;
            final pendingCount = total - completedCount;
            final overdueCount = activeTodos.where((t) => !t.isDone && t.dueDate != null && t.dueDate!.isBefore(DateTime.now())).length;

            final completionRate = total > 0 ? (completedCount / total) : 0.0;

            // Generate daily completion stats for the past 7 days
            final weekdayStats = _calculateWeekdayStats(completed);

            // Focus calculations
            final totalFocusSeconds = activeTodos.fold<int>(0, (sum, todo) => sum + todo.focusDurationSeconds);
            final focusHours = totalFocusSeconds ~/ 3600;
            final focusMinutes = (totalFocusSeconds % 3600) ~/ 60;
            
            String focusTimeStr = '0 phút';
            if (focusHours > 0) {
              focusTimeStr = '${focusHours}h ${focusMinutes}m';
            } else if (focusMinutes > 0) {
              focusTimeStr = '${focusMinutes} phút';
            } else if (totalFocusSeconds > 0) {
              focusTimeStr = '${totalFocusSeconds}s';
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Apple Health-Style Activity Ring Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomPaint(
                        size: const Size(100, 100),
                        painter: ActivityRingPainter(
                          progress: completionRate,
                          ringColor: const Color(0xFF34C759),
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tỉ lệ hoàn thành",
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: inkColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${(completionRate * 100).toInt()}% Công việc đã xong",
                              style: TextStyle(
                                fontFamily: 'SF Pro Text',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF34C759),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Nỗ lực nhiều hơn để hoàn tất tất cả mục tiêu trong ngày nhé!",
                              style: TextStyle(
                                fontFamily: 'SF Pro Text',
                                fontSize: 12,
                                color: inkMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Statistics Grid (2x2 Layout)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  childAspectRatio: 1.7,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard('Tổng cộng', total.toString(), const Color(0xFF007AFF), isDark),
                    _buildStatCard('Đã làm xong', completedCount.toString(), const Color(0xFF34C759), isDark),
                    _buildStatCard('Đang chờ', pendingCount.toString(), const Color(0xFFFF9500), isDark),
                    _buildStatCard('Tập trung', focusTimeStr, const Color(0xFFAF52DE), isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Overdue highlight card
                if (overdueCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF3B30), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF3B30)),
                        const SizedBox(width: 12),
                        Text(
                          "Cảnh báo: Bạn đang có $overdueCount việc quá hạn!",
                          style: const TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF3B30),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // 3. Weekly Activity Bar Chart
                Text(
                  "Hoạt động tuần này",
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: inkColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: BarChartPainter(
                      data: weekdayStats,
                      barColor: const Color(0xFF007AFF),
                      textColor: inkColor,
                      lineColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FutureBuilder<String>(
                  future: AIService().getCoachAdvice(
                    completed: completedCount,
                    pending: pendingCount,
                    overdue: overdueCount,
                    focusSeconds: totalFocusSeconds,
                  ),
                  builder: (context, snapshot) {
                    String adviceText = 'Đang tải lời khuyên từ Trợ lý AI...';
                    bool loading = true;

                    if (snapshot.connectionState == ConnectionState.done) {
                      loading = false;
                      adviceText = snapshot.data ?? 'Không thể tải lời khuyên năng suất lúc này.';
                    }

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark 
                              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                              : [const Color(0xFFF3F8FF), const Color(0xFFE6F0FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFB3D1FF),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.sparkles, color: Color(0xFF0066CC), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Lời khuyên từ Trợ lý AI",
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: inkColor,
                                ),
                              ),
                              if (loading) ...[
                                const Spacer(),
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0066CC)),
                                ),
                              ]
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            adviceText,
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 14,
                              height: 1.45,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<double> _calculateWeekdayStats(List<TodoEntity> completedTodos) {
    final List<double> stats = List.filled(7, 0.0);
    final now = DateTime.now();

    // Map each day of the last 7 days (index 0 is 6 days ago, index 6 is today)
    for (final todo in completedTodos) {
      if (todo.dueDate != null) {
        final diff = now.difference(todo.dueDate!).inDays;
        if (diff >= 0 && diff < 7) {
          stats[6 - diff] += 1.0;
        }
      } else {
        // Fallback to createdAt if no due date
        final diff = now.difference(todo.createdAt).inDays;
        if (diff >= 0 && diff < 7) {
          stats[6 - diff] += 1.0;
        }
      }
    }
    return stats;
  }
}

class ActivityRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color backgroundColor;

  ActivityRingPainter({
    required this.progress,
    required this.ringColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.12;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    final double angle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final Color barColor;
  final Color textColor;
  final Color lineColor;

  BarChartPainter({
    required this.data,
    required this.barColor,
    required this.textColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.isEmpty ? 5.0 : (data.reduce(max) < 5.0 ? 5.0 : data.reduce(max));
    final width = size.width;
    final height = size.height;

    final axisPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // Draw horizontal grid lines (3 lines)
    for (int i = 1; i <= 3; i++) {
      final y = height - (height * i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), axisPaint);
    }

    // Draw baseline
    canvas.drawLine(Offset(0, height), Offset(width, height), axisPaint);

    final numDays = data.length;
    final spacing = width / (numDays * 2);
    final barWidth = width / (numDays * 2);

    final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final now = DateTime.now();
    
    // Map day names correctly
    final List<String> currentWeekdays = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      currentWeekdays.add(weekdays[date.weekday - 1]);
    }

    for (int i = 0; i < numDays; i++) {
      final val = data[i];
      final barHeight = maxVal > 0 ? (val / maxVal) * (height - 30) : 0.0;
      final x = spacing + (i * (barWidth + spacing * 1.5));
      final y = height - barHeight;

      // Draw Bar
      if (barHeight > 0) {
        final rRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        );
        canvas.drawRRect(rRect, barPaint);
      }

      // Draw Value text on top of bar
      if (val > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: val.toInt().toString(),
            style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(x + (barWidth - textPainter.width) / 2, y - 16));
      }

      // Draw Day label below baseline
      final labelPainter = TextPainter(
        text: TextSpan(
          text: currentWeekdays[i],
          style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 10, fontFamily: 'SF Pro Text'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas, Offset(x + (barWidth - labelPainter.width) / 2, height + 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
