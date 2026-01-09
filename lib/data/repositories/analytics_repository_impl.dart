import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/data/datasources/local/app_database.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction_summary.dart';
import 'package:mobile_project_spending_management/domain/entities/category_breakdown.dart';
import 'package:mobile_project_spending_management/domain/entities/daily_summary.dart';
import 'package:mobile_project_spending_management/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AppDatabase database;

  AnalyticsRepositoryImpl(this.database);

  @override
  Future<Either<Failure, TransactionSummary>> getTransactionSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get all transactions in the date range
      final transactions = await (database.select(database.transactions)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate)))
          .get();

      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in transactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      return Right(TransactionSummary(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        transactionCount: transactions.length,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryBreakdown>>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
    required String type,
  }) async {
    try {
      // Query to get transactions grouped by category
      final query = database.select(database.transactions).join([
        innerJoin(
          database.categories,
          database.categories.id.equalsExp(database.transactions.categoryId),
        ),
      ])
        ..where(
          database.transactions.date.isBiggerOrEqualValue(startDate) &
              database.transactions.date.isSmallerOrEqualValue(endDate) &
              database.transactions.type.equals(type),
        );

      final results = await query.get();

      // Group by category and calculate totals
      final Map<int, Map<String, dynamic>> categoryMap = {};
      double totalAmount = 0;

      for (final row in results) {
        final transaction = row.readTable(database.transactions);
        final category = row.readTable(database.categories);

        if (!categoryMap.containsKey(category.id)) {
          categoryMap[category.id] = {
            'categoryId': category.id,
            'categoryName': category.name,
            'icon': category.icon,
            'color': category.color,
            'amount': 0.0,
            'count': 0,
          };
        }

        categoryMap[category.id]!['amount'] =
            (categoryMap[category.id]!['amount'] as double) + transaction.amount;
        categoryMap[category.id]!['count'] =
            (categoryMap[category.id]!['count'] as int) + 1;
        totalAmount += transaction.amount;
      }

      // Convert to list and calculate percentages
      final breakdowns = categoryMap.values.map((data) {
        final amount = data['amount'] as double;
        final percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0;

        return CategoryBreakdown(
          categoryId: data['categoryId'] as int,
          categoryName: data['categoryName'] as String,
          icon: data['icon'] as String,
          color: data['color'] as String,
          amount: amount,
          percentage: percentage.toDouble(),
          transactionCount: data['count'] as int,
        );
      }).toList();

      // Sort by amount descending
      breakdowns.sort((a, b) => b.amount.compareTo(a.amount));

      return Right(breakdowns);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailySummary>>> getDailySummaries({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await (database.select(database.transactions)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate)))
          .get();

      // Group transactions by date
      final Map<String, Map<String, double>> dailyMap = {};

      for (final transaction in transactions) {
        final dateKey = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        ).toIso8601String();

        if (!dailyMap.containsKey(dateKey)) {
          dailyMap[dateKey] = {'income': 0.0, 'expense': 0.0};
        }

        if (transaction.type == 'income') {
          dailyMap[dateKey]!['income'] =
              (dailyMap[dateKey]!['income'] ?? 0) + transaction.amount;
        } else {
          dailyMap[dateKey]!['expense'] =
              (dailyMap[dateKey]!['expense'] ?? 0) + transaction.amount;
        }
      }

      // Convert to list
      final summaries = dailyMap.entries.map((entry) {
        final income = entry.value['income'] ?? 0;
        final expense = entry.value['expense'] ?? 0;

        return DailySummary(
          date: DateTime.parse(entry.key),
          income: income,
          expense: expense,
          balance: income - expense,
        );
      }).toList();

      // Sort by date
      summaries.sort((a, b) => a.date.compareTo(b.date));

      return Right(summaries);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryBreakdown>>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    required String type,
    required int limit,
  }) async {
    try {
      final result = await getCategoryBreakdown(
        startDate: startDate,
        endDate: endDate,
        type: type,
      );

      return result.fold(
        (failure) => Left(failure),
        (breakdowns) {
          final topCategories = breakdowns.take(limit).toList();
          return Right(topCategories);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getAvailableAnchors({
    required String period,
  }) async {
    try {
      final transactions = await database.select(database.transactions).get();

      if (transactions.isEmpty) {
        return const Right(<DateTime>[]);
      }

      DateTime startOfWeek(DateTime d) {
        final monday = d.subtract(Duration(days: d.weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      }

      final Set<DateTime> anchors = {};
      for (final t in transactions) {
        final dt = t.date;
        switch (period) {
          case 'week':
            anchors.add(startOfWeek(dt));
            break;
          case 'month':
            anchors.add(DateTime(dt.year, dt.month, 1));
            break;
          case 'year':
            anchors.add(DateTime(dt.year, 1, 1));
            break;
          default:
            anchors.add(DateTime(dt.year, dt.month, dt.day));
        }
      }

      final sorted = anchors.toList()
        ..sort((a, b) => b.compareTo(a));

      return Right(sorted);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
