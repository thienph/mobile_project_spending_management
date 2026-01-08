import 'package:dartz/dartz.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories({required String type});
  Future<Either<Failure, Category>> getCategoryById(int id);
  Future<Either<Failure, List<Category>>> getAllCategories();
}
