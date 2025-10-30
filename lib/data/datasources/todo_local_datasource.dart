import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> addTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
  Future<void> updateTodoStatus(int id, bool newStatus);
  Future<void> updateTodo(int id, String newTitle);
}
