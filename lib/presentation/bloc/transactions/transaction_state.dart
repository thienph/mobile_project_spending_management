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
  final Map<String, double>? balance;

  const TransactionLoaded(this.transactions, {this.balance});

  @override
  List<Object?> get props => [transactions, balance];
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

class BalanceLoaded extends TransactionState {
  final Map<String, double> balance; // {openingBalance, income, expense, closingBalance}

  const BalanceLoaded(this.balance);

  @override
  List<Object?> get props => [balance];
}
