import 'package:equatable/equatable.dart';
import '../../../domain/entities/todo_list_entity.dart';

abstract class ListEvent extends Equatable {
  const ListEvent();

  @override
  List<Object?> get props => [];
}

class LoadListsEvent extends ListEvent {}

class AddListEvent extends ListEvent {
  final TodoListEntity list;
  const AddListEvent(this.list);

  @override
  List<Object?> get props => [list];
}

class DeleteListEvent extends ListEvent {
  final String id;
  const DeleteListEvent(this.id);

  @override
  List<Object?> get props => [id];
}
