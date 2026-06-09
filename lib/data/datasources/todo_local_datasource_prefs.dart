import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/data/datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';
import '../models/todo_list_model.dart';

class TodoLocalDataSourcePrefsImpl implements TodoLocalDataSource {
  static const String _key = 'todo_list';

  @override
  Future<List<TodoModel>> getTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(
      _key,
    ); //Thực hiện lấy nội dung từ (_key) thông qua biến jsonString
    if (jsonString == null) {
      return []; //Nếu biến jsonString = null, trả về list rỗng
    }
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
      final updatedTodo = TodoModel.fromEntity(
        todos[index].copyWith(isDone: newStatus),
      ); //Thực hiện cập nhật trạng thái todo, giữ nguyên các thông tin khác.
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
  Future<void> updateTodo(TodoModel todo) async {
    print('💾 DataSource: updateTodo(${todo.id})');
    final prefs = await SharedPreferences.getInstance();
    final todos = await getTodos();

    //Tìm Todo có id khớp
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      print('🔴 DataSource: Cập nhật thành công todo #${todo.id}');

      //Mã hoá lại thành dạng JSON
      final encoded = json.encode(todos.map((e) => e.toJson()).toList());
      await prefs.setString(
        _key,
        encoded,
      ); //Lưu lại vào SharedPreference (_key)
    }
  }

  static const String _listKey = 'todo_lists';

  @override
  Future<List<TodoListModel>> getLists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_listKey);
    if (jsonString == null) {
      return [];
    }
    print('🔴 DataSource: Lấy thành công danh sách thư mục');
    final List decoded = json.decode(jsonString);
    return decoded.map((e) => TodoListModel.fromJson(e)).toList();
  }

  @override
  Future<void> addList(TodoListModel list) async {
    final prefs = await SharedPreferences.getInstance();
    final lists = await getLists();
    lists.add(list);
    final encoded = json.encode(lists.map((e) => e.toJson()).toList());
    await prefs.setString(_listKey, encoded);
    print('🔴 DataSource: Thêm thư mục thành công: ${list.name}');
  }

  @override
  Future<void> deleteList(String id) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Delete list folder
    final lists = await getLists();
    lists.removeWhere((l) => l.id == id);
    final encoded = json.encode(lists.map((e) => e.toJson()).toList());
    await prefs.setString(_listKey, encoded);
    
    // 2. Cascade delete all todos associated with this list
    final todos = await getTodos();
    todos.removeWhere((t) => t.listId == id);
    final encodedTodos = json.encode(todos.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encodedTodos);
    print('🔴 DataSource: Xoá thư mục và dọn dẹp công việc thuộc thư mục có id: $id');
  }
}
