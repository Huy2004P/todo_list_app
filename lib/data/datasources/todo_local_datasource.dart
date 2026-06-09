import '../models/todo_model.dart';
import '../models/todo_list_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> addTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
  Future<void> updateTodoStatus(int id, bool newStatus);
  Future<void> updateTodo(TodoModel todo);

  // Custom Folders / Lists support
  Future<List<TodoListModel>> getLists();
  Future<void> addList(TodoListModel list);
  Future<void> deleteList(String id);
}
