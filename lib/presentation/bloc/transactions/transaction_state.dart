import 'package:equatable/equatable.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
}

class TransactionInitial extends TransactionState {
  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState {
  @override
  List<Object?> get props => [];
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  const TransactionLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionAdded extends TransactionState {
  @override
  List<Object?> get props => [];
}

class TransactionUpdated extends TransactionState {
  @override
  List<Object?> get props => [];
}

class TransactionDeleted extends TransactionState {
  @override
  List<Object?> get props => [];
}
