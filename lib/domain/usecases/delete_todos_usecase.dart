import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../repositories/todo_repository.dart';

class DeleteTodoUseCase {
  final TodoRepository repository;
  DeleteTodoUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    //Nhận nhiệm vụ xoá 1 Todo có id được chỉ định từ Bloc
    print('🔵 USECASE: DeleteTodoUseCase → gọi Repository');
    try {
      await repository.deleteTodo(
        id,
      ); //Gọi repository interface để thực hiện hành động deleteTodo
      return const Right(null);
    } catch (e) {
      print('🔵 USECASE: DeleteTodoUseCase → lỗi: $e');
      return Left(CacheFailure());
    }
  }
}
