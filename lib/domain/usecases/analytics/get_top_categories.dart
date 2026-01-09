import 'package:dartz/dartz.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/domain/entities/category_breakdown.dart';
import 'package:mobile_project_spending_management/domain/repositories/analytics_repository.dart';

class GetTopCategories {
  final AnalyticsRepository repository;

  GetTopCategories(this.repository);

  Future<Either<Failure, List<CategoryBreakdown>>> call({
    required DateTime startDate,
    required DateTime endDate,
    required String type,
    int limit = 5,
  }) async {
    return await repository.getTopCategories(
      startDate: startDate,
      endDate: endDate,
      type: type,
      limit: limit,
    );
  }
}
