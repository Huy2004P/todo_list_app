import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../repositories/todo_repository.dart';

class UpdateTodosUsecase {
  final TodoRepository repository;

  UpdateTodosUsecase(this.repository);

  Future<Either<Failure, void>> call(int id, String newTitle) async {
    //Nhận nhiệm vụ update nội dung của một todo được chỉ định id sẵn với nội dung mới được truyền vào (newTitle).
    print('🔵 USECASE: UpdateTodosUsecase → gọi Repository');
    try {
      await repository.updateTodo(
        id,
        newTitle,
      ); //Gọi repository interface để thực hiện updateTodo.
      print(
        '🔵 USECASE: UpdateTodosUsecase → cập nhật thành công id=$id → "$newTitle"',
      );
      return const Right(null);
    } catch (e) {
      print('🔵 USECASE: UpdateTodosUsecase → lỗi: $e');
      return Left(CacheFailure());
    }
  }
}
