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
  List<Object?> get props => [todo];
}

class DeleteTaskEvent extends TaskEvent {
  final int id;
  const DeleteTaskEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdateTaskStatusEvent extends TaskEvent {
  final int id;
  final bool newStatus;
  const UpdateTaskStatusEvent(this.id, this.newStatus);
  @override
  List<Object?> get props => [id, newStatus];
}

class UpdateTaskEvent extends TaskEvent {
  final TodoEntity todo;
  const UpdateTaskEvent(this.todo);
  @override
  List<Object?> get props => [todo];
}

class SearchTasksEvent extends TaskEvent {
  final String query;
  const SearchTasksEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterTasksByCategoryEvent extends TaskEvent {
  final String category;
  const FilterTasksByCategoryEvent(this.category);
  @override
  List<Object?> get props => [category];
}

class FilterTasksByPriorityEvent extends TaskEvent {
  final String priority;
  const FilterTasksByPriorityEvent(this.priority);
  @override
  List<Object?> get props => [priority];
}

class SortTasksEvent extends TaskEvent {
  final String sortBy;
  const SortTasksEvent(this.sortBy);
  @override
  List<Object?> get props => [sortBy];
}

class ToggleSubtaskEvent extends TaskEvent {
  final int todoId;
  final String subtaskId;
  final bool isDone;
  const ToggleSubtaskEvent({
    required this.todoId,
    required this.subtaskId,
    required this.isDone,
  });
  @override
  List<Object?> get props => [todoId, subtaskId, isDone];
}

// Smart Filters, Trash, and Backup events
class ChangeFilterEvent extends TaskEvent {
  final String filter; // 'All', 'Today', 'Scheduled', 'Flagged', 'Completed', 'Trash', or specific listId
  const ChangeFilterEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}

class MoveToTrashEvent extends TaskEvent {
  final int id;
  const MoveToTrashEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class RestoreFromTrashEvent extends TaskEvent {
  final int id;
  const RestoreFromTrashEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class DeletePermanentlyEvent extends TaskEvent {
  final int id;
  const DeletePermanentlyEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class BackupDataEvent extends TaskEvent {}

class RestoreDataEvent extends TaskEvent {}

class UpdateTaskFocusDurationEvent extends TaskEvent {
  final int taskId;
  final int addedSeconds;

  const UpdateTaskFocusDurationEvent({
    required this.taskId,
    required this.addedSeconds,
  });

  @override
  List<Object?> get props => [taskId, addedSeconds];
}


