import 'package:dartz/dartz.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction_summary.dart';
import 'package:mobile_project_spending_management/domain/repositories/analytics_repository.dart';

class GetTransactionSummary {
  final AnalyticsRepository repository;

  GetTransactionSummary(this.repository);

  Future<Either<Failure, TransactionSummary>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await repository.getTransactionSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
