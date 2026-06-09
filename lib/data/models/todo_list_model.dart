import '../../domain/entities/todo_list_entity.dart';

class TodoListModel extends TodoListEntity {
  const TodoListModel({
    required super.id,
    required super.name,
    super.iconName = 'list',
    super.colorHex = 0xFF0066CC,
  });

  factory TodoListModel.fromEntity(TodoListEntity entity) {
    return TodoListModel(
      id: entity.id,
      name: entity.name,
      iconName: entity.iconName,
      colorHex: entity.colorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorHex': colorHex,
    };
  }

  factory TodoListModel.fromJson(Map<String, dynamic> json) {
    return TodoListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String? ?? 'list',
      colorHex: json['colorHex'] as int? ?? 0xFF0066CC,
    );
  }
}
