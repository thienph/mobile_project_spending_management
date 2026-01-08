import 'package:mobile_project_spending_management/domain/entities/category.dart';
import 'package:mobile_project_spending_management/data/datasources/local/app_database.dart'
    as drift_db;

class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final String color;
  final String type;
  final bool isDefault;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
    required this.createdAt,
  });

  /// Convert Drift row to CategoryModel
  factory CategoryModel.fromDrift(drift_db.Category row) {
    return CategoryModel(
      id: row.id,
      name: row.name,
      icon: row.icon,
      color: row.color,
      type: row.type,
      isDefault: row.isDefault,
      createdAt: row.createdAt,
    );
  }

  /// Convert to domain entity
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: type,
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }
}
