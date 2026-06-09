import '../entities/todo_entity.dart';
import '../entities/todo_list_entity.dart';

//Định nghĩa các thao tác mà tầng data sẽ thực hiện sau này.
abstract class TodoRepository {
  Future<List<TodoEntity>> getTodos();
  Future<void> addTodo(TodoEntity todo);
  Future<void> deleteTodo(int id);
  Future<void> updateTodoStatus(int id, bool newStatus);
  Future<void> updateTodo(TodoEntity todo);

  // Custom Folders / Lists support
  Future<List<TodoListEntity>> getLists();
  Future<void> addList(TodoListEntity list);
  Future<void> deleteList(String id);
}

//Nhận dữ liệu từ repository_implement về trả về các usecase tương ứng

