class SubTaskEntity {
  final String id;
  final String title;
  final bool isDone;

  const SubTaskEntity({
    required this.id,
    required this.title,
    required this.isDone,
  });

  SubTaskEntity copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) {
    return SubTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
