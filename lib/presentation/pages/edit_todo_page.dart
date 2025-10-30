import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/task_bloc.dart';
import '../../application/bloc/task_event.dart';

class EditTodoPage extends StatefulWidget {
  final int id;
  final String oldTitle;

  const EditTodoPage({super.key, required this.id, required this.oldTitle});

  @override
  State<StatefulWidget> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late TextEditingController _controller;
  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.oldTitle);
  } //Khởi tạo và hiện thông số tiêu đề được truyền vào đúng theo id

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _saveChanges() {
    final newTitle = _controller.text.trim();

    if (newTitle.isEmpty) return;

    //Gửi UpdateTaskEvent đến bloc
    context.read<TaskBloc>().add(UpdateTaskEvent(widget.id, newTitle));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa công việc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Tên công việc mới',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    //Kiểm tra TextBoxController có được nhập không or empty.
                    return 'Vui lòng nhập tên công việc';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  print('🟢 UI: Đã ấn vào nút cập nhật todo!');
                  if (_formkey.currentState!.validate()) {
                    _saveChanges(); //Gọi hàm savechanges để gửi UpdateTodoEvent qua bloc
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
