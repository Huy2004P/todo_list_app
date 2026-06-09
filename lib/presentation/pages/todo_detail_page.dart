import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../application/bloc/task_bloc.dart';
import '../../application/bloc/task_event.dart';
import '../../application/bloc/task_state.dart';
import '../../application/bloc/list_bloc.dart';
import '../../application/bloc/list_state.dart';
import '../../domain/entities/todo_entity.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/entities/subtask_entity.dart';
import '../../core/services/ai_service.dart';
import 'edit_todo_page.dart';

class TodoDetailPage extends StatefulWidget {
  final int id;
  const TodoDetailPage({super.key, required this.id});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final TextEditingController _subtaskController = TextEditingController();
  bool _isAILoading = false;
  
  // Audio playback state
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Bind audio listeners
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateAIBreakdown(TodoEntity todo) async {
    setState(() {
      _isAILoading = true;
    });

    try {
      final suggestions = await AIService().generateSubtasks(todo.title);
      if (suggestions.isNotEmpty && mounted) {
        final List<SubTaskEntity> newSubtasks = [...todo.subtasks];
        for (final title in suggestions) {
          if (!newSubtasks.any((s) => s.title.toLowerCase() == title.toLowerCase())) {
            newSubtasks.add(SubTaskEntity(
              id: '${DateTime.now().millisecondsSinceEpoch}_${title.hashCode}',
              title: title,
              isDone: false,
            ));
          }
        }
        context.read<TaskBloc>().add(
          UpdateTaskEvent(todo.copyWith(subtasks: newSubtasks)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã phân tách công việc bằng AI thành công! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Lỗi phân tách AI: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAILoading = false;
        });
      }
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444); // High Red
      case 'medium':
        return const Color(0xFFF59E0B); // Amber Orange
      case 'low':
        return const Color(0xFF0066CC); // Action Blue
      default:
        return const Color(0xFF7A7A7A);
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Cao';
      case 'medium':
        return 'Trung bình';
      case 'low':
        return 'Thấp';
      default:
        return 'Thường';
    }
  }

  String _getCategoryLabel(String category) {
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

  String _getRecurrenceLabel(String rec) {
    switch (rec.toLowerCase()) {
      case 'daily':
        return 'Hàng ngày';
      case 'weekly':
        return 'Hàng tuần';
      case 'monthly':
        return 'Hàng tháng';
      case 'yearly':
        return 'Hàng năm';
      case 'none':
      default:
        return 'Không lặp lại';
    }
  }

  String _formatDateTime(DateTime dt) {
    final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$timeStr $dateStr';
  }

  void _addNewSubtask(TodoEntity todo) {
    final title = _subtaskController.text.trim();
    if (title.isNotEmpty) {
      final newSub = SubTaskEntity(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        isDone: false,
      );
      final updatedSubtasks = [...todo.subtasks, newSub];
      context.read<TaskBloc>().add(
            UpdateTaskEvent(todo.copyWith(subtasks: updatedSubtasks)),
          );
      _subtaskController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _deleteSubtask(TodoEntity todo, String subId) {
    final updatedSubtasks = todo.subtasks.where((s) => s.id != subId).toList();
    context.read<TaskBloc>().add(
          UpdateTaskEvent(todo.copyWith(subtasks: updatedSubtasks)),
        );
  }

  void _toggleAudioPlayback(String path) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(path));
      }
    } catch (e) {
      print('Lỗi phát âm thanh: $e');
    }
  }

  void _showImageFullscreen(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Container(
          color: Colors.black87,
          child: Center(
            child: InteractiveViewer(
              child: Image.file(File(path)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final Color inkMuted = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF7A7A7A);
    final Color canvasColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is TaskLoaded) {
          final todoIdx = state.allTodos.indexWhere((t) => t.id == widget.id);
          if (todoIdx == -1) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text("Không tìm thấy công việc này!"),
              ),
            );
          }

          final todo = state.allTodos[todoIdx];

          // Calculations
          final hasSubtasks = todo.subtasks.isNotEmpty;
          final totalSub = todo.subtasks.length;
          final completedSub = todo.subtasks.where((s) => s.isDone).length;
          final double subtaskProgress = hasSubtasks ? (completedSub / totalSub) : 0.0;
          final isOverdue = !todo.isDone && todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now());

          // Find Folder Info
          String? listName;
          int? listColorHex;
          final listState = context.read<ListBloc>().state;
          if (listState is ListLoaded && todo.listId != null) {
            final matched = listState.lists.where((l) => l.id == todo.listId);
            if (matched.isNotEmpty) {
              listName = matched.first.name;
              listColorHex = matched.first.colorHex;
            }
          }

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('Chi tiết', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: inkColor, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_note, size: 24),
                  tooltip: "Chỉnh sửa",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditTodoPage(
                          id: todo.id,
                          oldTodo: todo,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Folder name if assigned
                    if (listName != null) ...[
                      Row(
                        children: [
                          Icon(Icons.folder, color: Color(listColorHex ?? 0xFF0066CC), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            listName,
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(listColorHex ?? 0xFF0066CC),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Task Header Panel (White tile, flat, hairline border)
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Toggle & Title Stack
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.read<TaskBloc>().add(
                                        UpdateTaskStatusEvent(
                                          todo.id,
                                          !todo.isDone,
                                        ),
                                      );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.only(top: 3, right: 12),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: todo.isDone ? const Color(0xFF0066CC) : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: todo.isDone
                                          ? const Color(0xFF0066CC)
                                          : (isDark ? const Color(0xFF475569) : const Color(0xFFE0E0E0)),
                                      width: 2,
                                    ),
                                  ),
                                  child: todo.isDone
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  todo.title,
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 24, // display-lg
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.374,
                                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                                    color: todo.isDone ? inkMuted : inkColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // Option tag lines
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              // Category chip
                              Chip(
                                avatar: Icon(Icons.category_outlined, size: 14, color: inkMuted),
                                label: Text(_getCategoryLabel(todo.category)),
                                shape: const StadiumBorder(),
                                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFFAFAFC),
                              ),
                              // Priority chip
                              Chip(
                                avatar: Icon(Icons.flag_outlined, size: 14, color: _getPriorityColor(todo.priority)),
                                label: Text("Độ ưu tiên: ${_getPriorityLabel(todo.priority)}"),
                                shape: const StadiumBorder(),
                                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFFAFAFC),
                              ),
                              if (todo.dueDate != null)
                                Chip(
                                  avatar: Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: isOverdue ? const Color(0xFFEF4444) : Colors.green,
                                  ),
                                  label: Text(
                                    isOverdue ? "Quá hạn: ${_formatDateTime(todo.dueDate!)}" : "Hạn chót: ${_formatDateTime(todo.dueDate!)}",
                                    style: TextStyle(
                                      color: isOverdue ? const Color(0xFFEF4444) : null,
                                      fontWeight: isOverdue ? FontWeight.w600 : null,
                                    ),
                                  ),
                                  shape: const StadiumBorder(),
                                  backgroundColor: isOverdue 
                                      ? const Color(0xFFEF4444).withOpacity(0.08) 
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFFAFAFC)),
                                ),
                              if (todo.recurrence != 'none' && todo.recurrence.isNotEmpty)
                                Chip(
                                  avatar: const Icon(Icons.autorenew, size: 14, color: Colors.blueAccent),
                                  label: Text("Lặp lại: ${_getRecurrenceLabel(todo.recurrence)}"),
                                  shape: const StadiumBorder(),
                                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFFAFAFC),
                                ),
                            ],
                          ),
                          if (todo.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: todo.tags.map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0066CC).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(fontFamily: 'SF Pro Text', fontSize: 12, color: Color(0xFF0066CC), fontWeight: FontWeight.w600),
                                ),
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Section
                    Text(
                      "Mô tả chi tiết",
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.374,
                        color: inkColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        (todo.description == null || todo.description!.trim().isEmpty)
                            ? "Không có mô tả chi tiết."
                            : todo.description!,
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 17,
                          height: 1.47,
                          letterSpacing: -0.374,
                          fontStyle: (todo.description == null || todo.description!.trim().isEmpty)
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: (todo.description == null || todo.description!.trim().isEmpty)
                              ? inkMuted
                              : inkColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Attached images
                    if (todo.imagePaths.isNotEmpty) ...[
                      Text(
                        "Hình ảnh đính kèm",
                        style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 17, fontWeight: FontWeight.w600, color: inkColor),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todo.imagePaths.length,
                          itemBuilder: (context, idx) {
                            final path = todo.imagePaths[idx];
                            return GestureDetector(
                              onTap: () => _showImageFullscreen(context, path),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  image: DecorationImage(
                                    image: FileImage(File(path)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Attached Voice Note player
                    if (todo.audioPath != null) ...[
                      Text(
                        "Bản ghi âm ghi chú",
                        style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 17, fontWeight: FontWeight.w600, color: inkColor),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: const Color(0xFF0066CC), size: 40),
                              onPressed: () => _toggleAudioPlayback(todo.audioPath!),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Slider(
                                    min: 0,
                                    max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                                    value: _position.inSeconds.toDouble(),
                                    onChanged: (val) async {
                                      await _audioPlayer.seek(Duration(seconds: val.toInt()));
                                    },
                                    activeColor: const Color(0xFF0066CC),
                                    inactiveColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
                                          style: TextStyle(fontSize: 10, color: inkMuted),
                                        ),
                                        Text(
                                          "${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}",
                                          style: TextStyle(fontSize: 10, color: inkMuted),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Subtasks checklist section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Công việc con (${completedSub}/${totalSub})",
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.374,
                            color: inkColor,
                          ),
                        ),
                        if (hasSubtasks)
                          Text(
                            "${(subtaskProgress * 100).toInt()}% hoàn thành",
                            style: const TextStyle(
                              fontFamily: 'SF Pro Text',
                              color: Color(0xFF0066CC),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    if (hasSubtasks) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: LinearProgressIndicator(
                          value: subtaskProgress,
                          minHeight: 6,
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            subtaskProgress == 1.0 ? Colors.green : const Color(0xFF0066CC),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Nút AI Phân Tách
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _isAILoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0066CC)),
                                ),
                              )
                            : TextButton.icon(
                                onPressed: () => _generateAIBreakdown(todo),
                                icon: const Icon(CupertinoIcons.sparkles, size: 14, color: Color(0xFF0066CC)),
                                label: const Text(
                                  'Phân tách bằng AI',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0066CC),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  backgroundColor: const Color(0xFF0066CC).withOpacity(0.08),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Inline Subtask Add input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subtaskController,
                            decoration: InputDecoration(
                              hintText: 'Thêm công việc con mới...',
                              filled: true,
                              fillColor: canvasColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9999),
                                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE0E0E0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9999),
                                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE0E0E0)),
                              ),
                            ),
                            onSubmitted: (_) => _addNewSubtask(todo),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _addNewSubtask(todo),
                          icon: const Icon(Icons.add, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CC),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Subtasks lists in white cards
                    if (hasSubtasks)
                      Material(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todo.subtasks.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
                          itemBuilder: (context, index) {
                            final sub = todo.subtasks[index];
                            return ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  context.read<TaskBloc>().add(
                                        ToggleSubtaskEvent(
                                          todoId: todo.id,
                                          subtaskId: sub.id,
                                          isDone: !sub.isDone,
                                        ),
                                      );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: sub.isDone ? const Color(0xFF0066CC) : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: sub.isDone
                                          ? const Color(0xFF0066CC)
                                          : (isDark ? const Color(0xFF475569) : const Color(0xFFE0E0E0)),
                                      width: 2,
                                    ),
                                  ),
                                  child: sub.isDone
                                      ? const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              title: Text(
                                sub.title,
                                style: TextStyle(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 17,
                                  decoration: sub.isDone ? TextDecoration.lineThrough : null,
                                  color: sub.isDone ? inkMuted : inkColor,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                                onPressed: () => _deleteSubtask(todo, sub.id),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            "Chưa có công việc con.",
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              color: inkMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        } else if (state is TaskError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text("Lỗi: ${state.message}")),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text("Đang khởi tạo...")),
          );
        }
      },
    );
  }
}
