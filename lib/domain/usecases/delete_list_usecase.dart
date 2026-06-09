import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../repositories/todo_repository.dart';

class DeleteListUseCase {
  final TodoRepository repository;

  DeleteListUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    try {
      await repository.deleteList(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
