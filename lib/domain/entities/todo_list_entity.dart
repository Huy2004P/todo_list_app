import 'package:equatable/equatable.dart';

class TodoListEntity extends Equatable {
  final String id;
  final String name;
  final String iconName; // Icon name matching key
  final int colorHex;    // Accent color hex

  const TodoListEntity({
    required this.id,
    required this.name,
    this.iconName = 'list',
    this.colorHex = 0xFF0066CC, // Action Blue default
  });

  TodoListEntity copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorHex,
  }) {
    return TodoListEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [id, name, iconName, colorHex];
}
