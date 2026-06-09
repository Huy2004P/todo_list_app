import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/application/bloc/task_bloc.dart';
import 'package:todoapp/application/bloc/task_event.dart';
import 'package:todoapp/application/bloc/task_state.dart';

class TrashPage extends StatelessWidget {
  const TrashPage({super.key});

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
          'Thùng rác',
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
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoaded) {
                final trashItems = state.allTodos.where((t) => t.isTrash).toList();
                if (trashItems.isNotEmpty) {
                  return TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Dọn sạch thùng rác?"),
                          content: const Text("Tất cả công việc trong thùng rác sẽ bị xóa vĩnh viễn và không thể khôi phục."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Hủy"),
                            ),
                            TextButton(
                              onPressed: () {
                                for (final item in trashItems) {
                                  context.read<TaskBloc>().add(DeletePermanentlyEvent(item.id));
                                }
                                Navigator.pop(ctx);
                              },
                              child: const Text("Xóa vĩnh viễn", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Dọn sạch',
                      style: TextStyle(color: Colors.redAccent, fontFamily: 'SF Pro Text', fontWeight: FontWeight.w600),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoaded) {
            final trashItems = state.allTodos.where((t) => t.isTrash).toList();
            
            if (trashItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 64, color: inkMuted),
                    const SizedBox(height: 16),
                    Text(
                      'Thùng rác trống',
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 16,
                        color: inkMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Các mục bị xóa sẽ tự động biến mất sau 30 ngày',
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 12,
                        color: inkMuted.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trashItems.length,
              itemBuilder: (context, index) {
                final item = trashItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontFamily: 'SF Pro Text',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: inkColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            if (item.deletedAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Đã xóa ngày: ${item.deletedAt!.day}/${item.deletedAt!.month}/${item.deletedAt!.year}",
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 11,
                                    color: inkMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Restore button
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green),
                        tooltip: "Khôi phục",
                        onPressed: () {
                          context.read<TaskBloc>().add(RestoreFromTrashEvent(item.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã khôi phục: "${item.title}"'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      // Delete permanently button
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        tooltip: "Xóa vĩnh viễn",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Xóa vĩnh viễn"),
                              content: Text("Xóa vĩnh viễn công việc \"${item.title}\"? Thao tác này không thể hoàn tác."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Hủy"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<TaskBloc>().add(DeletePermanentlyEvent(item.id));
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
