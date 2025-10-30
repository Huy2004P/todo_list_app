import 'package:dartz/dartz.dart';
import 'package:todoapp/domain/entities/todo_entity.dart';
import '../repositories/todo_repository.dart';
import '../../core/error/failure.dart';

//Lấy danh sách todo từ repository
class GetToDosUseCase {
  final TodoRepository repository;

  GetToDosUseCase(this.repository);

  Future<Either<Failure, List<TodoEntity>>> call() async {
    print('🔵 USECASE: GetToDosUseCase → gọi Repository');
    try {
      final todos = await repository.getTodos();
      print('🔵 USECASE: GetToDosUseCase → lấy được ${todos.length} items');
      return Right(todos);
    } catch (e) {
      print('🔵 USECASE: GetToDosUseCase → lỗi: $e');
      return Left(CacheFailure());
    }
  }
}
