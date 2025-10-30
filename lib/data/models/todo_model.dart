import '../../domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    required int id,
    required String title,
    required bool isDone,
  }) : super(id: id, title: title, isDone: isDone);

  //Chuyển Entity(Domain) -> Model(Data)
  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(id: entity.id, title: entity.title, isDone: entity.isDone);
  }

  //Chuyển Model -> Map(JSON)
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isDone': isDone};

  //CHuyển Map(Json) -> Model
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
    );
  }
}
