import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/data/datasources/local/app_database.dart';
import 'package:mobile_project_spending_management/data/models/transaction_model.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart'
    as entity;
import 'package:mobile_project_spending_management/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase database;

  TransactionRepositoryImpl(this.database);

  @override
  Future<Either<Failure, List<entity.Transaction>>> getTransactions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await (database.select(database.transactions)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.date, mode: drift.OrderingMode.desc)]))
          .get();

      return Right(models.map((m) => TransactionModel.fromDrift(m).toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, entity.Transaction>> getTransactionById(int id) async {
    try {
      final model = await (database.select(database.transactions)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (model == null) {
        return Left(NotFoundFailure('Transaction not found'));
      }

      return Right(TransactionModel.fromDrift(model).toDomain());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<entity.Transaction>>> getTransactionsByCategory({
    required int categoryId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await (database.select(database.transactions)
            ..where((t) =>
                t.categoryId.equals(categoryId) &
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.date, mode: drift.OrderingMode.desc)]))
          .get();

      return Right(models.map((m) => TransactionModel.fromDrift(m).toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch transactions by category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<entity.Transaction>>> getTransactionsByType({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await (database.select(database.transactions)
            ..where((t) =>
                t.type.equals(type) &
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.date, mode: drift.OrderingMode.desc)]))
          .get();

      return Right(models.map((m) => TransactionModel.fromDrift(m).toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch transactions by type: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(entity.Transaction transaction) async {
    try {
      await database.into(database.transactions).insert(
            TransactionModel.fromDomain(transaction).toDrift(),
          );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(entity.Transaction transaction) async {
    try {
      final success = await database.update(database.transactions).replace(
            TransactionModel.fromDomain(transaction).toDrift(),
          );

      if (!success) {
        return Left(NotFoundFailure('Transaction not found for update'));
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(int id) async {
    try {
      final success = await (database.delete(database.transactions)
            ..where((t) => t.id.equals(id)))
          .go();

      if (success == 0) {
        return Left(NotFoundFailure('Transaction not found for deletion'));
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalByType({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await (database.select(database.transactions)
            ..where((t) =>
                t.type.equals(type) &
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate)))
          .get();

      final total = models.fold<double>(0, (sum, t) => sum + t.amount);

      return Right(total);
    } catch (e) {
      return Left(DatabaseFailure('Failed to calculate total: $e'));
    }
  }

  @override
  Future<Either<Failure, List<entity.Transaction>>> searchTransactions({
    required String query,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await (database.select(database.transactions)
            ..where((t) =>
                (t.description.like('%$query%') |
                    t.note.like('%$query%')) &
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.date, mode: drift.OrderingMode.desc)]))
          .get();

      return Right(models.map((m) => TransactionModel.fromDrift(m).toDomain()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to search transactions: $e'));
    }
  }
}
