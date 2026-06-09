import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/todo_list_entity.dart';
import '../repositories/todo_repository.dart';

class AddListUseCase {
  final TodoRepository repository;

  AddListUseCase(this.repository);

  Future<Either<Failure, void>> call(TodoListEntity list) async {
    try {
      await repository.addList(list);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
