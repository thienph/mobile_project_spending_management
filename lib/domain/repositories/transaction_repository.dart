import 'package:dartz/dartz.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';

abstract class TransactionRepository {
  /// Get all transactions between [startDate] and [endDate]
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get a single transaction by [id]
  Future<Either<Failure, Transaction>> getTransactionById(int id);

  /// Get transactions by [categoryId]
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory({
    required int categoryId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get transactions by [type] ('income' or 'expense')
  Future<Either<Failure, List<Transaction>>> getTransactionsByType({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Add a new transaction
  Future<Either<Failure, void>> addTransaction(Transaction transaction);

  /// Update an existing transaction
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);

  /// Delete a transaction by [id]
  Future<Either<Failure, void>> deleteTransaction(int id);

  /// Get total income/expense for a period
  Future<Either<Failure, double>> getTotalByType({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Search transactions by [description]
  Future<Either<Failure, List<Transaction>>> searchTransactions({
    required String query,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get cumulative balance up to [upToDate] (income - expense)
  Future<Either<Failure, double>> getCumulativeBalance({
    required DateTime upToDate,
  });

  /// Get balance for a specific period
  Future<Either<Failure, Map<String, double>>> getPeriodBalance({
    required DateTime startDate,
    required DateTime endDate,
  });
}
