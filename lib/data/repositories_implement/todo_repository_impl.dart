import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  TodoRepositoryImpl(this.localDataSource);

  @override
  Future<List<TodoEntity>> getTodos() async {
    print('🟣 REPO: getTodos() → gọi DataSource');
    final todos = await localDataSource
        .getTodos(); //nhận dữ liệu từ model đã được chuyển đổi từ datasource
    return todos; //trả về một list todos về repository interface
  }

  @override
  Future<void> addTodo(TodoEntity todo) async {
    //Nhận todo từ Usecase
    print('🟣 REPO: addTodo() → gọi DataSource');
    final model = TodoModel.fromEntity(todo); //chuyển todo sang model
    await localDataSource.addTodo(
      model,
    ); //gọi Datasource để thực hiện thêm todo mới
  }

  @override
  Future<void> deleteTodo(int id) async {
    //Nhận todo từ Usecase
    print('🟣 REPO: deleteTodo() → gọi DataSource');
    await localDataSource.deleteTodo(
      id,
    ); //Gọi datasource để xoá todo với id được chỉ định.
  }

  @override
  Future<void> UpdateTodoStatus(int id, bool newStatus) async {
    //Nhận todo từ Usecase
    print('🟣 REPO: updateTodoStatus() → gọi DataSource');
    await localDataSource.updateTodoStatus(
      id,
      newStatus,
    ); //Gọi datasrouce để cập nhật trạng thái todo với id được chỉ định và newStatus(true or false).
  }

  @override
  Future<void> updateTodo(int id, String newTitle) async {
    //Nhận todo từ Usecase
    print('🟣 REPO: updateTodo() → gọi DataSource');
    await localDataSource.updateTodo(id, newTitle);
  } //Gọi datasrouce để cập nhật todo với id được chỉ định và newTitle.
}
