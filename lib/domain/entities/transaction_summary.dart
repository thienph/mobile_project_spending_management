import 'package:equatable/equatable.dart';

class TransactionSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;
  final DateTime startDate;
  final DateTime endDate;

  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        balance,
        transactionCount,
        startDate,
        endDate,
      ];
}
