import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_project_spending_management/domain/usecases/categories/get_categories.dart';
import 'package:mobile_project_spending_management/domain/usecases/categories/get_all_categories.dart';
import 'package:mobile_project_spending_management/presentation/bloc/categories/category_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/categories/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final GetAllCategories getAllCategories;

  CategoryBloc({
    required this.getCategories,
    required this.getAllCategories,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadAllCategories>(_onLoadAllCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await getCategories(type: event.type);

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> _onLoadAllCategories(
    LoadAllCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await getAllCategories();

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }
}
