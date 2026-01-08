import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int? id;
  final double amount;
  final String? description;
  final DateTime date;
  final int categoryId;
  final String type; // 'income' or 'expense'
  final String? note;
  final bool isRecurring;
  final int? recurringTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.categoryId,
    required this.type,
    this.note,
    this.isRecurring = false,
    this.recurringTransactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        date,
        categoryId,
        type,
        note,
        isRecurring,
        recurringTransactionId,
        createdAt,
        updatedAt,
      ];
}
