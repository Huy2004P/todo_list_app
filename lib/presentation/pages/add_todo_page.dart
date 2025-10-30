import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/task_bloc.dart';
import '../../application/bloc/task_event.dart';
import '../../domain/entities/todo_entity.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm Công Việc Mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên công việc',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên công việc';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Lưu công việc'),
                onPressed: () {
                  print('🟢 UI: Đã ấn vào nút thêm todo!');
                  if (_formkey.currentState!.validate()) {
                    final todo = TodoEntity(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: _titleController.text,
                      isDone: false,
                    );

                    context.read<TaskBloc>().add(
                      AddTaskEvent(todo),
                    ); // Gửi AddTaskEvent sang tầng Bloc

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thêm công việc mới!')),
                    );

                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
