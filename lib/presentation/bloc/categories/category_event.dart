import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
}

class LoadCategories extends CategoryEvent {
  final String type; // 'income' or 'expense'

  const LoadCategories(this.type);

  @override
  List<Object?> get props => [type];
}

class LoadAllCategories extends CategoryEvent {
  const LoadAllCategories();

  @override
  List<Object?> get props => [];
}
