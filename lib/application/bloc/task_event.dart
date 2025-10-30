import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_entity.dart';

//Xác định những thao tác muốn thực hiện (Thêm, xoá, update statuc)
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class LoadTaskEvent extends TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final TodoEntity todo;
  const AddTaskEvent(this.todo);
  @override
  // TODO: implement props
  List<Object?> get props => [todo];
}

class DeleteTaskEvent extends TaskEvent {
  final int id;
  const DeleteTaskEvent(this.id);
  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class UpdateTaskStatusEvent extends TaskEvent {
  final int id;
  final bool newStatus;
  const UpdateTaskStatusEvent(this.id, this.newStatus);
  @override
  // TODO: implement props
  List<Object?> get props => [id, newStatus];
}

class UpdateTaskEvent extends TaskEvent {
  final int id;
  final String newTitle;
  const UpdateTaskEvent(this.id, this.newTitle);
  @override
  // TODO: implement props
  List<Object?> get props => [id, newTitle];
}
