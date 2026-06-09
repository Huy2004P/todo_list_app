import 'package:flutter/material.dart';
import '../../domain/entities/todo_entity.dart';

class TodoTitle extends StatelessWidget {
  final TodoEntity todo;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const TodoTitle({
    super.key,
    required this.todo,
    this.onChanged,
    this.onDelete,
    this.onEdit,
    this.onTap,
  });

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

  String _formatDateTime(DateTime dt) {
    final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$timeStr $dateStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Subtask calculations
    final hasSubtasks = todo.subtasks.isNotEmpty;
    final totalSub = todo.subtasks.length;
    final completedSub = todo.subtasks.where((s) => s.isDone).length;
    final double subtaskProgress = hasSubtasks ? (completedSub / totalSub) : 0.0;

    // Overdue calculations
    final isOverdue = !todo.isDone && todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now());

    // Apple text colors
    final Color inkColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final Color inkMuted = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF7A7A7A);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(18), // rounded.lg (18px)
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Badge Headers (Category, Priority, and Edit/Delete buttons)
              Row(
                children: [
                  // Category Badge (Apple Pill)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066CC).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(9999), // rounded.pill
                    ),
                    child: Text(
                      _getCategoryLabel(todo.category),
                      style: const TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.224,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Priority Badge (Apple Pill)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(todo.priority).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(9999), // rounded.pill
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 11,
                          color: _getPriorityColor(todo.priority),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _getPriorityLabel(todo.priority),
                          style: TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.224,
                            color: _getPriorityColor(todo.priority),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Edit / Delete buttons
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: inkMuted,
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.redAccent.withOpacity(0.8),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Circle Checkbox & H1 Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => onChanged?.call(!todo.isDone),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(top: 1, right: 12),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: todo.isDone ? const Color(0xFF0066CC) : Colors.transparent,
                        shape: BoxShape.circle, // Circular Control
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 17, // 17px
                            fontWeight: FontWeight.w600, // 600 weight
                            letterSpacing: -0.374, // Apple tight tracking
                            decoration: todo.isDone ? TextDecoration.lineThrough : null,
                            color: todo.isDone ? inkMuted : inkColor,
                          ),
                        ),
                        if (todo.description != null && todo.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            todo.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 14,
                              height: 1.47,
                              letterSpacing: -0.224,
                              color: inkMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // 3. Due Date and Subtask Progress
              if (todo.dueDate != null || hasSubtasks) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Deadline or Focus Duration (if no deadline)
                    if (todo.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: isOverdue ? const Color(0xFFEF4444) : inkMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(todo.dueDate!),
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 12,
                              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                              letterSpacing: -0.12,
                              color: isOverdue ? const Color(0xFFEF4444) : inkMuted,
                            ),
                          ),
                        ],
                      )
                    else if (todo.focusDurationSeconds > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 13,
                            color: Color(0xFF0066CC),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${(todo.focusDurationSeconds / 60).toStringAsFixed(1)}p tập trung",
                            style: const TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0066CC),
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(),

                    // Checklist & Focus Duration (if has deadline)
                    Row(
                      children: [
                        if (todo.dueDate != null && todo.focusDurationSeconds > 0) ...[
                          const Icon(
                            Icons.timer_outlined,
                            size: 13,
                            color: Color(0xFF0066CC),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${(todo.focusDurationSeconds / 60).toStringAsFixed(1)}p",
                            style: const TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0066CC),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (hasSubtasks)
                          Row(
                            children: [
                              Icon(
                                Icons.checklist,
                                size: 13,
                                color: inkMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "$completedSub/$totalSub việc con",
                                style: TextStyle(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 12,
                                  letterSpacing: -0.12,
                                  color: inkMuted,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                if (hasSubtasks) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9999), // Pill progress
                    child: LinearProgressIndicator(
                      value: subtaskProgress,
                      minHeight: 4,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        subtaskProgress == 1.0 ? Colors.green : const Color(0xFF0066CC),
                      ),
                    ),
                  ),
                ]
              ],
            ],
          ),
        ),
      ),
    );
  }
}
