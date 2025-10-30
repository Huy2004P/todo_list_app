import 'package:get_it/get_it.dart';
import 'package:todoapp/application/bloc/task_bloc.dart';
import 'package:todoapp/domain/usecases/update_todos_usecase.dart';
import '../../data/datasources/todo_local_datasource.dart';
import '../../data/datasources/todo_local_datasource_prefs.dart';
import '../../data/repositories_implement/todo_repository_impl.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/usecases/add_todos_usecase.dart';
import '../../domain/usecases/delete_todos_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/update_todos_status_usecase.dart';

final sl = GetIt.instance;

// Future<void> init() async {
//   //ToDo: Dùng để đăng kí UseCase, Repository, các Bloc
//   //Datasource
//   sl.registerLazySingleton<TodoLocalDataSource>(
//     () => TodoLocalDataSourcePrefsImpl(),
//   );

//   //Repository
//   sl.registerLazySingleton<TodoRepository>(
//     () => TodoRepositoryImpl(sl()), // inject interface
//   );

//   //Usecase
//   sl.registerLazySingleton(() => GetToDosUseCase(sl()));
//   sl.registerLazySingleton(() => AddTodoUseCase(sl()));
//   sl.registerLazySingleton(() => DeleteTodoUseCase(sl()));
//   sl.registerLazySingleton(() => UpdateTodoStatusUsecase(sl()));

//   //Bloc
//   sl.registerFactory(
//     () => TaskBloc(
//       getTodos: sl(),
//       addTodo: sl(),
//       deleteTodo: sl(),
//       updateStatus: sl(),
//     ),
//   );
// }

Future<void> init() async {
  print("Registering DataSource...");
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourcePrefsImpl(),
  );

  print("Registering Repository...");
  sl.registerLazySingleton<TodoRepository>(() => TodoRepositoryImpl(sl()));

  print("Registering UseCases...");
  sl.registerLazySingleton(() => GetToDosUseCase(sl()));
  sl.registerLazySingleton(() => AddTodoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTodoUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTodoStatusUsecase(sl()));
  sl.registerLazySingleton(() => UpdateTodosUsecase(sl()));

  print("Registering Bloc...");
  sl.registerFactory(
    () => TaskBloc(
      getTodos: sl(),
      addTodo: sl(),
      deleteTodo: sl(),
      updateStatus: sl(),
      updateTodo: sl(),
    ),
  );

  print("Tất cả Dependency đã được đăng ký!");
}
