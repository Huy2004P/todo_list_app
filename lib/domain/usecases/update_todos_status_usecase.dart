import 'package:dartz/dartz.dart';
import '../repositories/todo_repository.dart';
import '../../core/error/failure.dart';

class UpdateTodoStatusUsecase {
  final TodoRepository repository;

  UpdateTodoStatusUsecase(this.repository);

  Future<Either<Failure, void>> call(int id, bool newStatus) async {
    //Nhận nhiệm vụ cập nhật trạng thái 1 Todo có id được chỉ định với trạng thái mới (true, false) từ Bloc
    print('🔵 USECASE: UpdateTodoStatusUsecase → gọi Repository');
    try {
      await repository.UpdateTodoStatus(
        id,
        newStatus,
      ); //Gọi repository interface để thực hiện thao tác updateStatusTask
      print(
        '🔵 USECASE: UpdateTodoStatusUsecase → cập nhật thành công id=$id → $newStatus',
      );
      return const Right(null);
    } catch (e) {
      print('🔵 USECASE: UpdateTodoStatusUsecase → lỗi: $e');
      return Left(CacheFailure());
    }
  }
}
