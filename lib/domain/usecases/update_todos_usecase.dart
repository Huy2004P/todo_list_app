import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class UpdateTodosUsecase {
  final TodoRepository repository;

  UpdateTodosUsecase(this.repository);

  Future<Either<Failure, void>> call(TodoEntity todo) async {
    print('🔵 USECASE: UpdateTodosUsecase → gọi Repository');
    try {
      await repository.updateTodo(todo);
      print(
        '🔵 USECASE: UpdateTodosUsecase → cập nhật thành công id=${todo.id}',
      );
      return const Right(null);
    } catch (e) {
      print('🔵 USECASE: UpdateTodosUsecase → lỗi: $e');
      return Left(CacheFailure());
    }
  }
}
