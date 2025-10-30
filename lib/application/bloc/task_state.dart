import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_entity.dart';

//Trạng thái hiện tại để UI hoặc console hiển thị.
abstract class TaskState extends Equatable {
  const TaskState();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TodoEntity> todos;
  const TaskLoaded(this.todos);
  @override
  // TODO: implement props
  List<Object?> get props => [todos];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  // TODO: implement props
  List<Object?> get props => [message];
}
