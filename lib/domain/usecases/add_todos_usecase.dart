import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../repositories/todo_repository.dart';
import '../entities/todo_entity.dart';

class AddTodoUseCase {
  final TodoRepository repository;
  AddTodoUseCase(this.repository);

  Future<Either<Failure, void>> call(TodoEntity todo) async {
    //Tầng này không biết cách lưu SQL Lite, SharedPrefereces hay API.
    //Nhận nhiệm vụ thêm 1 Todo mới từ  Bloc
    print('🔵 USECASE: AddTodoUseCase → gọi Repository');
    try {
      await repository.addTodo(
        todo,
      ); //Gọi repository interface để thực thi hành động addTodo
      return const Right(null);
    } catch (e) {
      print('🔵 USECASE: AddTodoUseCase → lỗi: $e');
      return Left(CacheFailure());
    }
  }
}
