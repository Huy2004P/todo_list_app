import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_lists_usecase.dart';
import '../../../domain/usecases/add_list_usecase.dart';
import '../../../domain/usecases/delete_list_usecase.dart';
import 'list_event.dart';
import 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  final GetListsUseCase getLists;
  final AddListUseCase addList;
  final DeleteListUseCase deleteList;

  ListBloc({
    required this.getLists,
    required this.addList,
    required this.deleteList,
  }) : super(ListInitial()) {
    on<LoadListsEvent>((event, emit) async {
      emit(ListLoading());
      final result = await getLists();
      result.fold(
        (failure) => emit(const ListError('Không thể tải danh sách thư mục')),
        (lists) => emit(ListLoaded(lists)),
      );
    });

    on<AddListEvent>((event, emit) async {
      await addList(event.list);
      add(LoadListsEvent());
    });

    on<DeleteListEvent>((event, emit) async {
      await deleteList(event.id);
      add(LoadListsEvent());
    });
  }
}
