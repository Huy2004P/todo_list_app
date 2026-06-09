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
  final List<TodoEntity> allTodos;
  final List<TodoEntity> filteredTodos;
  final String searchQuery;
  final String selectedCategory;
  final String selectedPriority;
  final String sortBy;
  final String currentFilter; // 'All', 'Today', 'Scheduled', 'Flagged', 'Completed', 'Trash', or specific listId

  const TaskLoaded({
    required this.allTodos,
    required this.filteredTodos,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.selectedPriority = 'All',
    this.sortBy = 'createdAt',
    this.currentFilter = 'Dashboard',
  });

  TaskLoaded copyWith({
    List<TodoEntity>? allTodos,
    List<TodoEntity>? filteredTodos,
    String? searchQuery,
    String? selectedCategory,
    String? selectedPriority,
    String? sortBy,
    String? currentFilter,
  }) {
    return TaskLoaded(
      allTodos: allTodos ?? this.allTodos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      sortBy: sortBy ?? this.sortBy,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  @override
  List<Object?> get props => [
        allTodos,
        filteredTodos,
        searchQuery,
        selectedCategory,
        selectedPriority,
        sortBy,
        currentFilter,
      ];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

