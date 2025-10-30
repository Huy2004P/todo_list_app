import 'package:flutter/material.dart';

class TodoTitle extends StatelessWidget {
  final String title;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TodoTitle({
    super.key,
    required this.title,
    required this.done,
    this.onChanged,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                print(
                  '🟢 UI: Tick todo "$title" → chuyển trạng thái từ $done thành ${!done}',
                );
                onChanged?.call(!done);
              },
            ),
            IconButton(
              onPressed: () {
                print('🟢 UI: Đã ấn vào nút xoá todo!');
                onDelete?.call();
              },
              icon: const Icon(Icons.delete, color: Colors.redAccent),
            ),
            IconButton(
              onPressed: () {
                print(
                  '🟢 UI: Đã ấn vào nút chỉnh sửa, chuyển sang màn hình cập nhật todo!',
                );
                onEdit?.call();
              },
              icon: const Icon(
                Icons.edit,
                color: Color.fromARGB(255, 4, 117, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
