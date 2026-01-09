import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';
import 'package:mobile_project_spending_management/domain/repositories/transaction_repository.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/add_transaction.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/delete_transaction.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/get_transactions.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/update_transaction.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final TransactionRepository repository;

  // Keep track of current transactions to preserve them when loading balance
  List<Transaction> _currentTransactions = [];

  TransactionBloc({
    required this.getTransactions,
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.repository,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<SearchTransactionsEvent>(_onSearchTransactions);
    on<LoadBalanceEvent>(_onLoadBalance);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    final result = await getTransactions(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) {
        _currentTransactions = transactions;
        emit(TransactionLoaded(transactions));
      },
    );
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await addTransaction(event.transaction);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => emit(TransactionAdded()),
    );
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await updateTransaction(event.transaction);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => emit(TransactionUpdated()),
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransaction(event.id);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => emit(TransactionDeleted()),
    );
  }

  Future<void> _onSearchTransactions(
    SearchTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    final result = await getTransactions(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (allTransactions) {
        final filtered = allTransactions
            .where((t) =>
                (t.description?.toLowerCase().contains(event.query.toLowerCase()) ??
                    false) ||
                (t.note?.toLowerCase().contains(event.query.toLowerCase()) ?? false))
            .toList();

        _currentTransactions = filtered;
        emit(TransactionLoaded(filtered));
      },
    );
  }

  Future<void> _onLoadBalance(
    LoadBalanceEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await repository.getPeriodBalance(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (balance) {
        // Preserve current transactions and add balance info
        if (_currentTransactions.isNotEmpty) {
          emit(TransactionLoaded(_currentTransactions, balance: balance));
        } else {
          emit(BalanceLoaded(balance));
        }
      },
    );
  }
}
