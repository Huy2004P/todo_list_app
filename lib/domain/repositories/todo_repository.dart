import '../entities/todo_entity.dart';

//Định nghĩa các thao tác mà tầng data sẽ thực hiện sau này.
abstract class TodoRepository {
  Future<List<TodoEntity>> getTodos();
  Future<void> addTodo(TodoEntity todo);
  Future<void> deleteTodo(int id);
  Future<void> UpdateTodoStatus(int id, bool newStatus);
  Future<void> updateTodo(int id, String newTitle);
}

//Nhận dữ liệu từ repository_implement về trả về các usecase tương ứng
