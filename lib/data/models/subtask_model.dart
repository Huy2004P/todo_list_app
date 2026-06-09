import '../../domain/entities/subtask_entity.dart';

class SubTaskModel extends SubTaskEntity {
  const SubTaskModel({
    required super.id,
    required super.title,
    required super.isDone,
  });

  factory SubTaskModel.fromEntity(SubTaskEntity entity) {
    return SubTaskModel(
      id: entity.id,
      title: entity.title,
      isDone: entity.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
      };

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}
