import '../../domain/entities/todo_entity.dart';
import 'subtask_model.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    required super.id,
    required super.title,
    super.description,
    required super.isDone,
    super.priority = 'medium',
    super.category = 'Others',
    super.dueDate,
    required super.createdAt,
    List<SubTaskModel> super.subtasks = const [],
    super.isTrash = false,
    super.deletedAt,
    super.recurrence = 'none',
    super.tags = const [],
    super.imagePaths = const [],
    super.audioPath,
    super.listId,
    super.focusDurationSeconds = 0,
  });

  //Chuyển Entity(Domain) -> Model(Data)
  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isDone: entity.isDone,
      priority: entity.priority,
      category: entity.category,
      dueDate: entity.dueDate,
      createdAt: entity.createdAt,
      subtasks: entity.subtasks.map((e) => SubTaskModel.fromEntity(e)).toList(),
      isTrash: entity.isTrash,
      deletedAt: entity.deletedAt,
      recurrence: entity.recurrence,
      tags: entity.tags,
      imagePaths: entity.imagePaths,
      audioPath: entity.audioPath,
      listId: entity.listId,
      focusDurationSeconds: entity.focusDurationSeconds,
    );
  }

  //Chuyển Model -> Map(JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'priority': priority,
      'category': category,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'subtasks': subtasks.map((e) => (e as SubTaskModel).toJson()).toList(),
      'isTrash': isTrash,
      'deletedAt': deletedAt?.toIso8601String(),
      'recurrence': recurrence,
      'tags': tags,
      'imagePaths': imagePaths,
      'audioPath': audioPath,
      'listId': listId,
      'focusDurationSeconds': focusDurationSeconds,
    };
  }

  //Chuyển Map(Json) -> Model
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    final subtasksJson = json['subtasks'] as List? ?? [];
    
    // Safely parse arrays
    final tagsRaw = json['tags'] as List? ?? [];
    final tagsList = tagsRaw.map((e) => e.toString()).toList();
    
    final imagePathsRaw = json['imagePaths'] as List? ?? [];
    final imagePathsList = imagePathsRaw.map((e) => e.toString()).toList();

    return TodoModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      isDone: json['isDone'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'medium',
      category: json['category'] as String? ?? 'Others',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      subtasks: subtasksJson.map((e) => SubTaskModel.fromJson(e as Map<String, dynamic>)).toList(),
      isTrash: json['isTrash'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      recurrence: json['recurrence'] as String? ?? 'none',
      tags: tagsList,
      imagePaths: imagePathsList,
      audioPath: json['audioPath'] as String?,
      listId: json['listId'] as String?,
      focusDurationSeconds: json['focusDurationSeconds'] as int? ?? 0,
    );
  }
}
