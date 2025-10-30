import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/domain/usecases/update_todos_usecase.dart';
import '../../domain/usecases/add_todos_usecase.dart';
import '../../domain/usecases/delete_todos_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/update_todos_status_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetToDosUseCase getTodos;
  final AddTodoUseCase addTodo;
  final DeleteTodoUseCase deleteTodo;
  final UpdateTodoStatusUsecase updateStatus;
  final UpdateTodosUsecase updateTodo;

  TaskBloc({
    required this.getTodos,
    required this.addTodo,
    required this.deleteTodo,
    required this.updateStatus,
    required this.updateTodo,
  }) : super(TaskInitial()) {
    on<LoadTaskEvent>((event, emit) async {
      print('🟡 BLOC: LoadTaskEvent → bắt đầu tải danh sách');
      emit(TaskLoading());
      final result = await getTodos();
      result.fold(
        (failure) {
          print('🟡 BLOC: LoadTaskEvent → lỗi khi tải');
          emit(const TaskError("Không thể tải danh sách Task"));
        },
        (todos) {
          print(
            '🟡 BLOC: LoadTaskEvent → tải thành công ${todos.length} items',
          );
          emit(TaskLoaded(todos));
        },
      );
    });

    on<AddTaskEvent>((event, emit) async {
      //Tầng bloc nhận được sự kiện AddTaskEvent từ AddPage.
      print('🟡 BLOC: Nhận được AddTaskEvent với Todo: ${event.todo.title}');
      await addTodo(event.todo); //Gọi AddTodo ở Usecase.
      add(LoadTaskEvent());
    });

    on<DeleteTaskEvent>((event, emit) async {
      //Nhận sự kiện DeleteTaskEvent với tham số id của todo được gửi từ DeleteButton ở Homepage.
      print('🟡 BLOC: Xoá Todo có id=${event.id}');
      await deleteTodo(event.id);
      add(LoadTaskEvent());
    });

    on<UpdateTaskStatusEvent>((event, emit) async {
      print(
        '🟡 BLOC: Cập nhật trạng thái Todo có id=${event.id}, newStatus=${event.newStatus}',
      ); //Nhận sự kiện UpdateTaskStatusEvent với tham số id, newStatus của todo từ Homepage.
      await updateStatus(event.id, event.newStatus);
      add(LoadTaskEvent());
    });

    on<UpdateTaskEvent>((event, emit) async {
      print(
        '🟡 BLOC: Cập nhật nội dung Todo có id=${event.id} → ${event.newTitle}',
      ); //Nhận sự kiện UpdateTaskEvent với tham số id, newTitle của todo từ EditPage
      await updateTodo(event.id, event.newTitle);
      add(LoadTaskEvent());
    });
  }
}
