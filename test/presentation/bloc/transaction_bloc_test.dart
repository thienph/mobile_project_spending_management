import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_project_spending_management/core/errors/failures.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';
import 'package:mobile_project_spending_management/domain/repositories/transaction_repository.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/add_transaction.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/delete_transaction.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/get_transactions.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/update_transaction.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_state.dart';

class MockGetTransactions extends Mock implements GetTransactions {}

class MockAddTransaction extends Mock implements AddTransaction {}

class MockUpdateTransaction extends Mock implements UpdateTransaction {}

class MockDeleteTransaction extends Mock implements DeleteTransaction {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late TransactionBloc transactionBloc;
  late MockGetTransactions mockGetTransactions;
  late MockAddTransaction mockAddTransaction;
  late MockUpdateTransaction mockUpdateTransaction;
  late MockDeleteTransaction mockDeleteTransaction;
  late MockTransactionRepository mockRepository;

  final testTransaction = Transaction(
    id: 1,
    amount: 50000,
    description: 'Test Transaction',
    date: DateTime.now(),
    categoryId: 1,
    type: 'expense',
    isRecurring: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(testTransaction);
  });

  setUp(() {
    mockGetTransactions = MockGetTransactions();
    mockAddTransaction = MockAddTransaction();
    mockUpdateTransaction = MockUpdateTransaction();
    mockDeleteTransaction = MockDeleteTransaction();
    mockRepository = MockTransactionRepository();

    transactionBloc = TransactionBloc(
      getTransactions: mockGetTransactions,
      addTransaction: mockAddTransaction,
      updateTransaction: mockUpdateTransaction,
      deleteTransaction: mockDeleteTransaction,
      repository: mockRepository,
    );
  });

  tearDown(() {
    transactionBloc.close();
  });

  group('TransactionBloc - LoadTransactions', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] when LoadTransactions succeeds',
      build: () {
        when(() => mockGetTransactions(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right([testTransaction]));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(
        LoadTransactions(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
        ),
      ),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
      ],
    );
  });

  group('TransactionBloc - AddTransaction', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionAdded, TransactionLoading, TransactionLoaded] when AddTransaction succeeds',
      build: () {
        when(() => mockAddTransaction(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetTransactions(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right([testTransaction]));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(AddTransactionEvent(testTransaction)),
      expect: () => [
        isA<TransactionAdded>(),
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
      ],
      verify: (bloc) {
        verify(() => mockAddTransaction(testTransaction)).called(1);
        verify(() => mockGetTransactions(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionError] when AddTransaction fails',
      build: () {
        when(() => mockAddTransaction(any())).thenAnswer(
            (_) async => Left(DatabaseFailure('Failed to add transaction')));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(AddTransactionEvent(testTransaction)),
      expect: () => [
        isA<TransactionError>(),
      ],
    );
  });

  group('TransactionBloc - DeleteTransaction', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionDeleted, TransactionLoading, TransactionLoaded] when DeleteTransaction succeeds',
      build: () {
        when(() => mockDeleteTransaction(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetTransactions(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right([]));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const DeleteTransactionEvent(1)),
      expect: () => [
        isA<TransactionDeleted>(),
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
      ],
    );
  });

  group('TransactionBloc - UpdateTransaction', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionUpdated, TransactionLoading, TransactionLoaded] when UpdateTransaction succeeds',
      build: () {
        when(() => mockUpdateTransaction(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetTransactions(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right([testTransaction]));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(UpdateTransactionEvent(testTransaction)),
      expect: () => [
        isA<TransactionUpdated>(),
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
      ],
    );
  });
}

