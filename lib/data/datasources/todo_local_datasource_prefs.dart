import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/data/datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';

class TodoLocalDataSourcePrefsImpl implements TodoLocalDataSource {
  static const String _key = 'todo_list';

  @override
  Future<List<TodoModel>> getTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(
      _key,
    ); //Thực hiện lấy nội dung từ (_key) thông qua biến jsonString
    if (jsonString == null)
      return []; //Nếu biến jsonString = null, trả về list rỗng
    print('🔴 DataSource: Lấy thành công danh sách todo');

    final List decoded = json.decode(
      jsonString,
    ); //Giải mã jsonString vào List decoded
    return decoded
        .map((e) => TodoModel.fromJson(e))
        .toList(); //Map decoded sang model sau đó trả về repository implement
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    //Đây là tầng thấp nhất
    final prefs = await SharedPreferences.getInstance();
    final todos = await getTodos();
    todos.add(todo); //Thực hiện thêm todo đã chuyển đổi sang model
    print('🔴 DataSource: Thêm thành công todo mới #$todo');

    //Mã hoá lại thành dạng JSON
    final encoded = json.encode(todos.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded); //Lưu lại vào SharedPreference (_key)
  }

  @override
  Future<void> deleteTodo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final todos = await getTodos();

    todos.removeWhere((t) => t.id == id); //Xoá todo có ID trùng khớp
    print('🔴 DataSource: Đã xoá thành công Todo có id: #$id');

    //Mã hoá lại thành dạng JSON
    final encoded = json.encode(todos.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded); //Lưu lại vào SharedPreference (_key)
  }

  @override
  Future<void> updateTodoStatus(int id, bool newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final todos = await getTodos();

    //Tìm Todo có id khớp
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final updatedTodo = TodoModel(
        id: todos[index].id,
        title: todos[index].title,
        isDone: newStatus,
      ); //Thực hiện cập nhật todo, chuyển đổi sang model với trạng thái isDone = trạng thái mới newStatus.
      todos[index] = updatedTodo;
      print(
        '🔴 DataSource: Cập nhật thành công trạng thái todo có #$id -> #$newStatus',
      );
    }

    //Mã hoá lại thành dạng JSON
    final encoded = json.encode(todos.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded); //Lưu lại vào SharedPreference (_key)
  }

  @override
  Future<void> updateTodo(int id, String newTitle) async {
    print('💾 DataSource: updateTodo($id, $newTitle)');
    final prefs = await SharedPreferences.getInstance();
    final todos = await getTodos();

    //Tìm Todo có id khớp
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      todos[index] = TodoModel(
        id: todos[index].id,
        title: newTitle,
        isDone: todos[index].isDone,
      ); //Thực hiện cập todo nhật, chuyển đổi sang model với nội dung title = nội dung mới newTitle.
      print('🔴 DataSource: Cập nhật thành công todo #$id');

      //Mã hoá lại thành dạng JSON
      final encoded = json.encode(todos.map((e) => e.toJson()).toList());
      await prefs.setString(
        _key,
        encoded,
      ); //Lưu lại vào SharedPreference (_key)
    }
  }
}
