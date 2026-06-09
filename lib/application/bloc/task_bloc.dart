import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/update_todos_usecase.dart';
import '../../domain/usecases/add_todos_usecase.dart';
import '../../domain/usecases/delete_todos_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/update_todos_status_usecase.dart';
import '../../data/models/todo_model.dart';
import '../../core/services/notification_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetToDosUseCase getTodos;
  final AddTodoUseCase addTodo;
  final DeleteTodoUseCase deleteTodo;
  final UpdateTodoStatusUsecase updateStatus;
  final UpdateTodosUsecase updateTodo;

  TaskBloc({
    required this.getTodos,
    required this.addTodo,
    required this.deleteTodo,
    required this.updateStatus,
    required this.updateTodo,
  }) : super(TaskInitial()) {
    on<LoadTaskEvent>((event, emit) async {
      print('🟡 BLOC: LoadTaskEvent → bắt đầu tải danh sách');
      
      String query = '';
      String category = 'All';
      String priority = 'All';
      String sortBy = 'createdAt';
      String filter = 'All';
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        query = current.searchQuery;
        category = current.selectedCategory;
        priority = current.selectedPriority;
        sortBy = current.sortBy;
        filter = current.currentFilter;
      }

      emit(TaskLoading());
      final result = await getTodos();
      result.fold(
        (failure) {
          print('🟡 BLOC: LoadTaskEvent → lỗi khi tải');
          emit(const TaskError("Không thể tải danh sách Task"));
        },
        (todos) {
          print(
            '🟡 BLOC: LoadTaskEvent → tải thành công ${todos.length} items',
          );
          
          // Auto permanent delete trash items older than 30 days
          final now = DateTime.now();
          for (final todo in todos) {
            if (todo.isTrash && todo.deletedAt != null) {
              final diff = now.difference(todo.deletedAt!).inDays;
              if (diff >= 30) {
                deleteTodo(todo.id);
              }
            }
          }

          final filtered = _filterAndSort(todos, query, category, priority, sortBy, filter);
          emit(TaskLoaded(
            allTodos: todos,
            filteredTodos: filtered,
            searchQuery: query,
            selectedCategory: category,
            selectedPriority: priority,
            sortBy: sortBy,
            currentFilter: filter,
          ));
        },
      );
    });

    on<AddTaskEvent>((event, emit) async {
      print('🟡 BLOC: Nhận được AddTaskEvent với Todo: ${event.todo.title}');
      await addTodo(event.todo);
      
      // Schedule local notification if due date exists
      if (event.todo.dueDate != null && !event.todo.isDone && !event.todo.isTrash) {
        await NotificationService().scheduleNotification(event.todo, 15); // Báo trước 15 phút
      }
      
      add(LoadTaskEvent());
    });

    on<DeleteTaskEvent>((event, emit) async {
      print('🟡 BLOC: Xoá Todo có id=${event.id}');
      await NotificationService().cancelNotification(event.id);
      await deleteTodo(event.id);
      add(LoadTaskEvent());
    });

    on<UpdateTaskStatusEvent>((event, emit) async {
      print(
        '🟡 BLOC: Cập nhật trạng thái Todo có id=${event.id}, newStatus=${event.newStatus}',
      );
      
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final index = current.allTodos.indexWhere((t) => t.id == event.id);
        if (index != -1) {
          final todo = current.allTodos[index];
          
          // Cập nhật status
          await updateStatus(event.id, event.newStatus);

          if (event.newStatus) {
            // Cancel notification when done
            await NotificationService().cancelNotification(event.id);
            
            // Xử lý Recurring / Lặp lại
            if (todo.recurrence != 'none' && todo.recurrence.isNotEmpty) {
              DateTime? nextDue;
              final currentDue = todo.dueDate ?? DateTime.now();
              switch (todo.recurrence.toLowerCase()) {
                case 'daily':
                case 'hàng ngày':
                  nextDue = currentDue.add(const Duration(days: 1));
                  break;
                case 'weekly':
                case 'hàng tuần':
                  nextDue = currentDue.add(const Duration(days: 7));
                  break;
                case 'monthly':
                case 'hàng tháng':
                  nextDue = DateTime(currentDue.year, currentDue.month + 1, currentDue.day);
                  break;
                case 'yearly':
                case 'hàng năm':
                  nextDue = DateTime(currentDue.year + 1, currentDue.month, currentDue.day);
                  break;
              }
              if (nextDue != null) {
                final nextTodo = TodoEntity(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: todo.title,
                  description: todo.description,
                  isDone: false,
                  priority: todo.priority,
                  category: todo.category,
                  dueDate: nextDue,
                  createdAt: DateTime.now(),
                  subtasks: todo.subtasks.map((e) => e.copyWith(isDone: false)).toList(),
                  recurrence: todo.recurrence,
                  tags: todo.tags,
                  imagePaths: todo.imagePaths,
                  audioPath: todo.audioPath,
                  listId: todo.listId,
                  isTrash: false,
                );
                await addTodo(nextTodo);
                
                // Schedule next task's notification
                await NotificationService().scheduleNotification(nextTodo, 15);
              }
            }
          } else {
            // Re-schedule notification if unmarked done
            if (todo.dueDate != null && !todo.isTrash) {
              await NotificationService().scheduleNotification(todo, 15);
            }
          }
        }
      }
      add(LoadTaskEvent());
    });

    on<UpdateTaskEvent>((event, emit) async {
      print('🟡 BLOC: Cập nhật Todo có id=${event.todo.id}');
      await updateTodo(event.todo);

      // Re-schedule or cancel notification
      if (event.todo.isDone || event.todo.isTrash || event.todo.dueDate == null) {
        await NotificationService().cancelNotification(event.todo.id);
      } else {
        await NotificationService().scheduleNotification(event.todo, 15);
      }

      add(LoadTaskEvent());
    });

    on<SearchTasksEvent>((event, emit) {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final filtered = _filterAndSort(
          current.allTodos,
          event.query,
          current.selectedCategory,
          current.selectedPriority,
          current.sortBy,
          current.currentFilter,
        );
        emit(current.copyWith(
          searchQuery: event.query,
          filteredTodos: filtered,
        ));
      }
    });

    on<FilterTasksByCategoryEvent>((event, emit) {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final filtered = _filterAndSort(
          current.allTodos,
          current.searchQuery,
          event.category,
          current.selectedPriority,
          current.sortBy,
          current.currentFilter,
        );
        emit(current.copyWith(
          selectedCategory: event.category,
          filteredTodos: filtered,
        ));
      }
    });

    on<FilterTasksByPriorityEvent>((event, emit) {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final filtered = _filterAndSort(
          current.allTodos,
          current.searchQuery,
          current.selectedCategory,
          event.priority,
          current.sortBy,
          current.currentFilter,
        );
        emit(current.copyWith(
          selectedPriority: event.priority,
          filteredTodos: filtered,
        ));
      }
    });

    on<SortTasksEvent>((event, emit) {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final filtered = _filterAndSort(
          current.allTodos,
          current.searchQuery,
          current.selectedCategory,
          current.selectedPriority,
          event.sortBy,
          current.currentFilter,
        );
        emit(current.copyWith(
          sortBy: event.sortBy,
          filteredTodos: filtered,
        ));
      }
    });

    on<ToggleSubtaskEvent>((event, emit) async {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final index = current.allTodos.indexWhere((t) => t.id == event.todoId);
        if (index != -1) {
          final todo = current.allTodos[index];
          final updatedSubtasks = todo.subtasks.map((sub) {
            if (sub.id == event.subtaskId) {
              return sub.copyWith(isDone: event.isDone);
            }
            return sub;
          }).toList();
          
          final updatedTodo = todo.copyWith(subtasks: updatedSubtasks);
          await updateTodo(updatedTodo);
          add(LoadTaskEvent());
        }
      }
    });

    // Smart Filters, Trash & Backup Events Handler
    on<ChangeFilterEvent>((event, emit) {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final filtered = _filterAndSort(
          current.allTodos,
          current.searchQuery,
          current.selectedCategory,
          current.selectedPriority,
          current.sortBy,
          event.filter,
        );
        emit(current.copyWith(
          currentFilter: event.filter,
          filteredTodos: filtered,
        ));
      }
    });

    on<MoveToTrashEvent>((event, emit) async {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final index = current.allTodos.indexWhere((t) => t.id == event.id);
        if (index != -1) {
          final todo = current.allTodos[index];
          final updated = todo.copyWith(isTrash: true, deletedAt: DateTime.now());
          await NotificationService().cancelNotification(todo.id);
          await updateTodo(updated);
        }
      }
      add(LoadTaskEvent());
    });

    on<RestoreFromTrashEvent>((event, emit) async {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final index = current.allTodos.indexWhere((t) => t.id == event.id);
        if (index != -1) {
          final todo = current.allTodos[index];
          final updated = todo.copyWith(isTrash: false, deletedAt: null);
          if (updated.dueDate != null && !updated.isDone) {
            await NotificationService().scheduleNotification(updated, 15);
          }
          await updateTodo(updated);
        }
      }
      add(LoadTaskEvent());
    });

    on<DeletePermanentlyEvent>((event, emit) async {
      await NotificationService().cancelNotification(event.id);
      await deleteTodo(event.id);
      add(LoadTaskEvent());
    });

    on<BackupDataEvent>((event, emit) async {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        try {
          final listJson = current.allTodos.map((e) => TodoModel.fromEntity(e).toJson()).toList();
          final jsonString = json.encode(listJson);
          
          final String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Chọn nơi lưu tệp sao lưu Todo',
            fileName: 'todo_backup.json',
            type: FileType.custom,
            allowedExtensions: ['json'],
          );

          if (outputFile != null) {
            final file = File(outputFile);
            await file.writeAsString(jsonString);
            print('💾 Sao lưu thành công: $outputFile');
          } else {
            // fallback sharing
            final tempDir = Directory.systemTemp;
            final file = File('${tempDir.path}/todo_backup.json');
            await file.writeAsString(jsonString);
            await Share.shareXFiles([XFile(file.path)], text: 'Dữ liệu Todo App');
          }
        } catch (e) {
          print('❌ Lỗi khi xuất backup: $e');
        }
      }
    });

    on<RestoreDataEvent>((event, emit) async {
      try {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          final content = await file.readAsString();
          final List decoded = json.decode(content);
          
          for (final item in decoded) {
            final model = TodoModel.fromJson(item as Map<String, dynamic>);
            // Check if exists, update it, else add it
            await addTodo(model);
          }
          print('💾 Khôi phục thành công từ tệp: ${result.files.single.path}');
          add(LoadTaskEvent());
        }
      } catch (e) {
        print('❌ Lỗi khi import backup: $e');
      }
    });

    on<UpdateTaskFocusDurationEvent>((event, emit) async {
      print('🟡 BLOC: Cập nhật thời gian tập trung cho Task id=${event.taskId}, thêm ${event.addedSeconds} giây');
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final index = current.allTodos.indexWhere((t) => t.id == event.taskId);
        if (index != -1) {
          final todo = current.allTodos[index];
          final updated = todo.copyWith(
            focusDurationSeconds: todo.focusDurationSeconds + event.addedSeconds,
          );
          await updateTodo(updated);
        }
      }
      add(LoadTaskEvent());
    });
  }

  List<TodoEntity> _filterAndSort(
    List<TodoEntity> list,
    String query,
    String category,
    String priority,
    String sortBy,
    String filter,
  ) {
    var result = List<TodoEntity>.from(list);

    // 1. Trash vs Active Filter
    if (filter == 'Trash') {
      result = result.where((todo) => todo.isTrash).toList();
    } else {
      result = result.where((todo) => !todo.isTrash).toList();

      // 2. Smart filters
      if (filter == 'Today') {
        final now = DateTime.now();
        result = result.where((todo) {
          if (todo.dueDate == null) return false;
          return todo.dueDate!.year == now.year &&
              todo.dueDate!.month == now.month &&
              todo.dueDate!.day == now.day;
        }).toList();
      } else if (filter == 'Scheduled') {
        result = result.where((todo) => todo.dueDate != null).toList();
      } else if (filter == 'Flagged') {
        result = result.where((todo) => todo.priority.toLowerCase() == 'high').toList();
      } else if (filter == 'Completed') {
        result = result.where((todo) => todo.isDone).toList();
      } else if (filter != 'All') {
        // filter by custom listId
        result = result.where((todo) => todo.listId == filter).toList();
      }
    }

    // 3. Search Query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      result = result.where((todo) {
        final titleMatch = todo.title.toLowerCase().contains(lowerQuery);
        final descMatch = todo.description?.toLowerCase().contains(lowerQuery) ?? false;
        final tagMatch = todo.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        return titleMatch || descMatch || tagMatch;
      }).toList();
    }

    // 4. Category Filter
    if (category != 'All') {
      result = result.where((todo) => todo.category.toLowerCase() == category.toLowerCase()).toList();
    }

    // 5. Priority Filter
    if (priority != 'All') {
      result = result.where((todo) => todo.priority.toLowerCase() == priority.toLowerCase()).toList();
    }

    // 6. Sorting
    if (sortBy == 'dueDate') {
      result.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else if (sortBy == 'priority') {
      int priorityWeight(String p) {
        switch (p.toLowerCase()) {
          case 'high':
            return 3;
          case 'medium':
            return 2;
          case 'low':
            return 1;
          default:
            return 0;
        }
      }
      result.sort((a, b) => priorityWeight(b.priority).compareTo(priorityWeight(a.priority)));
    } else if (sortBy == 'alphabetical') {
      result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return result;
  }
}

