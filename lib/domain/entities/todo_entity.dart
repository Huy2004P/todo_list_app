import 'subtask_entity.dart';

class TodoEntity {
  final int id;
  final String title;
  final String? description;
  final bool isDone;
  final String priority; // 'low', 'medium', 'high'
  final String category; // 'Work', 'Personal', 'Shopping', etc.
  final DateTime? dueDate;
  final DateTime createdAt;
  final List<SubTaskEntity> subtasks;
  final bool isTrash;
  final DateTime? deletedAt;
  final String recurrence; // 'none', 'daily', 'weekly', 'monthly', 'yearly'
  final List<String> tags;
  final List<String> imagePaths;
  final String? audioPath;
  final String? listId; // Custom list folder association
  final int focusDurationSeconds; // Total focused time in seconds

  const TodoEntity({
    required this.id,
    required this.title,
    this.description,
    required this.isDone,
    this.priority = 'medium',
    this.category = 'Others',
    this.dueDate,
    required this.createdAt,
    this.subtasks = const [],
    this.isTrash = false,
    this.deletedAt,
    this.recurrence = 'none',
    this.tags = const [],
    this.imagePaths = const [],
    this.audioPath,
    this.listId,
    this.focusDurationSeconds = 0,
  });

  TodoEntity copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    String? priority,
    String? category,
    DateTime? dueDate,
    DateTime? createdAt,
    List<SubTaskEntity>? subtasks,
    bool? isTrash,
    DateTime? deletedAt,
    String? recurrence,
    List<String>? tags,
    List<String>? imagePaths,
    String? audioPath,
    String? listId,
    int? focusDurationSeconds,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
      isTrash: isTrash ?? this.isTrash,
      deletedAt: deletedAt ?? this.deletedAt,
      recurrence: recurrence ?? this.recurrence,
      tags: tags ?? this.tags,
      imagePaths: imagePaths ?? this.imagePaths,
      audioPath: audioPath ?? this.audioPath,
      listId: listId ?? this.listId,
      focusDurationSeconds: focusDurationSeconds ?? this.focusDurationSeconds,
    );
  }
}