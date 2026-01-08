import 'package:dartz/dartz.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/data/datasources/local/app_database.dart'
    as drift_db;
import 'package:mobile_project_spending_management/data/models/category_model.dart';
import 'package:mobile_project_spending_management/domain/entities/category.dart';
import 'package:mobile_project_spending_management/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final drift_db.AppDatabase database;

  CategoryRepositoryImpl(this.database);

  @override
  Future<Either<Failure, List<Category>>> getCategories({
    required String type,
  }) async {
    try {
      final models = await (database.select(database.categories)
            ..where((c) => c.type.equals(type)))
          .get();

      return Right(models.map((m) => CategoryModel.fromDrift(m).toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch categories: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(int id) async {
    try {
      final model = await (database.select(database.categories)
            ..where((c) => c.id.equals(id)))
          .getSingleOrNull();

      if (model == null) {
        return Left(NotFoundFailure('Category not found'));
      }

      return Right(CategoryModel.fromDrift(model).toDomain());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final models = await database.select(database.categories).get();
      return Right(models.map((m) => CategoryModel.fromDrift(m).toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch all categories: $e'));
    }
  }
}
