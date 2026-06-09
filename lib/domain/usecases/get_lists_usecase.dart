import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/todo_list_entity.dart';
import '../repositories/todo_repository.dart';

class GetListsUseCase {
  final TodoRepository repository;

  GetListsUseCase(this.repository);

  Future<Either<Failure, List<TodoListEntity>>> call() async {
    try {
      final result = await repository.getLists();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
