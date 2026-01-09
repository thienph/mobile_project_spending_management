import 'package:dartz/dartz.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/domain/entities/category_breakdown.dart';
import 'package:mobile_project_spending_management/domain/repositories/analytics_repository.dart';

class GetCategoryBreakdown {
  final AnalyticsRepository repository;

  GetCategoryBreakdown(this.repository);

  Future<Either<Failure, List<CategoryBreakdown>>> call({
    required DateTime startDate,
    required DateTime endDate,
    required String type,
  }) async {
    return await repository.getCategoryBreakdown(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }
}
