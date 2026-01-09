import 'package:dartz/dartz.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction_summary.dart';
import 'package:mobile_project_spending_management/domain/entities/category_breakdown.dart';
import 'package:mobile_project_spending_management/domain/entities/daily_summary.dart';

abstract class AnalyticsRepository {
  /// Get transaction summary for a given period
  Future<Either<Failure, TransactionSummary>> getTransactionSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get category breakdown for expenses
  Future<Either<Failure, List<CategoryBreakdown>>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    required String type, // 'income' or 'expense'
  });

  /// Get daily summaries for trend analysis
  Future<Either<Failure, List<DailySummary>>> getDailySummaries({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get top spending categories
  Future<Either<Failure, List<CategoryBreakdown>>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    required String type,
    required int limit,
  });
}
