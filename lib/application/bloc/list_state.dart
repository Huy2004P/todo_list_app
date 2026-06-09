import 'package:equatable/equatable.dart';
import '../../../domain/entities/todo_list_entity.dart';

abstract class ListState extends Equatable {
  const ListState();

  @override
  List<Object?> get props => [];
}

class ListInitial extends ListState {}

class ListLoading extends ListState {}

class ListLoaded extends ListState {
  final List<TodoListEntity> lists;
  const ListLoaded(this.lists);

  @override
  List<Object?> get props => [lists];
}

class ListError extends ListState {
  final String message;
  const ListError(this.message);

  @override
  List<Object?> get props => [message];
}
