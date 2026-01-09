import 'package:equatable/equatable.dart';

class CategoryBreakdown extends Equatable {
  final int categoryId;
  final String categoryName;
  final String icon;
  final String color;
  final double amount;
  final double percentage;
  final int transactionCount;

  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        icon,
        color,
        amount,
        percentage,
        transactionCount,
      ];
}
