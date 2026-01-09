import 'package:mobile_project_spending_management/domain/entities/category_breakdown.dart';

class CategoryBreakdownModel extends CategoryBreakdown {
  const CategoryBreakdownModel({
    required super.categoryId,
    required super.categoryName,
    required super.icon,
    required super.color,
    required super.amount,
    required super.percentage,
    required super.transactionCount,
  });

  factory CategoryBreakdownModel.fromEntity(CategoryBreakdown entity) {
    return CategoryBreakdownModel(
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      icon: entity.icon,
      color: entity.color,
      amount: entity.amount,
      percentage: entity.percentage,
      transactionCount: entity.transactionCount,
    );
  }

  CategoryBreakdown toEntity() {
    return CategoryBreakdown(
      categoryId: categoryId,
      categoryName: categoryName,
      icon: icon,
      color: color,
      amount: amount,
      percentage: percentage,
      transactionCount: transactionCount,
    );
  }
}
