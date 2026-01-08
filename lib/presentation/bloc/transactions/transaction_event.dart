import 'package:equatable/equatable.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
}

class LoadTransactions extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadTransactions({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadTransactionsByCategory extends TransactionEvent {
  final int categoryId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadTransactionsByCategory({
    required this.categoryId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [categoryId, startDate, endDate];
}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final int id;

  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchTransactionsEvent extends TransactionEvent {
  final String query;
  final DateTime startDate;
  final DateTime endDate;

  const SearchTransactionsEvent({
    required this.query,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [query, startDate, endDate];
}
