import 'package:dartz/dartz.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/domain/entities/daily_summary.dart';
import 'package:mobile_project_spending_management/domain/repositories/analytics_repository.dart';

class GetDailySummaries {
  final AnalyticsRepository repository;

  GetDailySummaries(this.repository);

  Future<Either<Failure, List<DailySummary>>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await repository.getDailySummaries(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
