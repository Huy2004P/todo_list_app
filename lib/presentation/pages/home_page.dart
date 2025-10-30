import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/application/bloc/task_bloc.dart';
import 'package:todoapp/application/bloc/task_event.dart';
import 'package:todoapp/application/bloc/task_state.dart';
import 'package:todoapp/presentation/pages/add_todo_page.dart';
import 'package:todoapp/presentation/pages/edit_todo_page.dart';
import '../../presentation/widgets/todo_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('HomePage.build() được gọi!');
    // final List<Map<String, dynamic>> todos = [
    //   {'title': 'Học Flutter', 'done': false},
    //   {'title': 'Viết nhật kí thực tập', 'done': true},
    //   {'title': 'Xây dựng AddTodoPage', 'done': false},
    // ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Công Việc Cần Làm'),
        actions: [
          IconButton(
            onPressed: () => context.read<TaskBloc>().add(LoadTaskEvent()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            final todos = state
                .todos; //Khai báo todos từ mảng state (Với state là trạng thái của các todo (khởi tạo, đang load, đã load, lỗi))

            if (todos.isEmpty) {
              return const Center(child: const Text("Chưa Có Công Việc Nào!"));
            }

            return ListView.builder(
              //Trả về listview.
              itemCount: todos
                  .length, //Số lượng item trong listview dựa theo todos sau khi load lên có bao nhiêu phần tử trong list.
              itemBuilder: (context, index) {
                final item = todos[index];
                return TodoTitle(
                  title: item.title,
                  done: item.isDone,
                  onChanged: (newValue) {
                    print('🟢 UI: Toggle status của ${item.title}');
                    context.read<TaskBloc>().add(
                      UpdateTaskStatusEvent(
                        item.id,
                        newValue!,
                      ), //Gửi UpdateTaskStatusEvent sang tầng bloc với 2 tham số (id của todo, giá trị (check or !check))
                    );
                  },
                  onDelete: () {
                    print('🟠 UI: Xoá ${item.title}');
                    context.read<TaskBloc>().add(
                      DeleteTaskEvent(item.id),
                    ); //Gửi DeleteTaskEvent sang tầng bloc với tham số id của todo.
                  },
                  onEdit: () {
                    print('✏️ UI: Sửa ${item.title}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditTodoPage(
                          id: item.id,
                          oldTitle: item.title,
                        ), //Gọi sang EditPage, truyền 3 tham số hiện có của todo
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is TaskError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          } else {
            return const Center(child: Text('Đang Khởi Tạo Dữ Liệu'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTodoPage(),
            ), //Gọi AddPage
          ),
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
