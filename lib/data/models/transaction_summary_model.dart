import 'package:mobile_project_spending_management/domain/entities/transaction_summary.dart';

class TransactionSummaryModel extends TransactionSummary {
  const TransactionSummaryModel({
    required super.totalIncome,
    required super.totalExpense,
    required super.balance,
    required super.transactionCount,
    required super.startDate,
    required super.endDate,
  });

  factory TransactionSummaryModel.fromEntity(TransactionSummary entity) {
    return TransactionSummaryModel(
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      balance: entity.balance,
      transactionCount: entity.transactionCount,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }

  TransactionSummary toEntity() {
    return TransactionSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      transactionCount: transactionCount,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
