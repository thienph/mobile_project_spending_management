import 'package:drift/drift.dart' as drift;
import 'package:mobile_project_spending_management/data/datasources/local/app_database.dart'
    show Transaction, TransactionsCompanion;
import 'package:mobile_project_spending_management/domain/entities/transaction.dart'
    as entity;

class TransactionModel {
  final int? id;
  final double amount;
  final String? description;
  final DateTime date;
  final int categoryId;
  final String type;
  final bool isRecurring;
  final int? recurringTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.categoryId,
    required this.type,
    this.isRecurring = false,
    this.recurringTransactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Drift row to TransactionModel
  factory TransactionModel.fromDrift(Transaction row) {
    return TransactionModel(
      id: row.id,
      amount: row.amount,
      description: row.description,
      date: row.date,
      categoryId: row.categoryId,
      type: row.type,
      isRecurring: row.isRecurring,
      recurringTransactionId: row.recurringTransactionId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Convert TransactionModel to Drift companion for insert/update
  TransactionsCompanion toDrift() {
    return TransactionsCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      amount: drift.Value(amount),
      description: description != null ? drift.Value(description) : const drift.Value.absent(),
      date: drift.Value(date),
      categoryId: drift.Value(categoryId),
      type: drift.Value(type),
      isRecurring: drift.Value(isRecurring),
      recurringTransactionId: recurringTransactionId != null
          ? drift.Value(recurringTransactionId)
          : const drift.Value.absent(),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
    );
  }

  /// Convert TransactionModel to domain Entity
  entity.Transaction toDomain() {
    return entity.Transaction(
      id: id,
      amount: amount,
      description: description,
      date: date,
      categoryId: categoryId,
      type: type,
      isRecurring: isRecurring,
      recurringTransactionId: recurringTransactionId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert domain Entity to TransactionModel
  factory TransactionModel.fromDomain(entity.Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      description: transaction.description,
      date: transaction.date,
      categoryId: transaction.categoryId,
      type: transaction.type,
      isRecurring: transaction.isRecurring,
      recurringTransactionId: transaction.recurringTransactionId,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }
}
