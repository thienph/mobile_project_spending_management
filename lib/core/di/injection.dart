import 'package:get_it/get_it.dart';
import 'package:mobile_project_spending_management/data/datasources/local/app_database.dart';
import 'package:mobile_project_spending_management/data/repositories/category_repository_impl.dart';
import 'package:mobile_project_spending_management/data/repositories/transaction_repository_impl.dart';
import 'package:mobile_project_spending_management/domain/repositories/category_repository.dart';
import 'package:mobile_project_spending_management/domain/repositories/transaction_repository.dart';
import 'package:mobile_project_spending_management/domain/usecases/categories/get_all_categories.dart';
import 'package:mobile_project_spending_management/domain/usecases/categories/get_categories.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/add_transaction.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/delete_transaction.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/get_transactions.dart';
import 'package:mobile_project_spending_management/domain/usecases/transactions/update_transaction.dart';
import 'package:mobile_project_spending_management/presentation/bloc/categories/category_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Repositories
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(getIt<AppDatabase>()),
  );

  // Use Cases - Categories
  getIt.registerLazySingleton<GetCategories>(
    () => GetCategories(getIt<CategoryRepository>()),
  );
  getIt.registerLazySingleton<GetAllCategories>(
    () => GetAllCategories(getIt<CategoryRepository>()),
  );

  // Use Cases - Transactions
  getIt.registerLazySingleton<GetTransactions>(
    () => GetTransactions(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<AddTransaction>(
    () => AddTransaction(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<UpdateTransaction>(
    () => UpdateTransaction(getIt<TransactionRepository>()),
  );
  getIt.registerLazySingleton<DeleteTransaction>(
    () => DeleteTransaction(getIt<TransactionRepository>()),
  );

  // BLoCs
  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      getCategories: getIt<GetCategories>(),
      getAllCategories: getIt<GetAllCategories>(),
    ),
  );
  getIt.registerFactory<TransactionBloc>(
    () => TransactionBloc(
      getTransactions: getIt<GetTransactions>(),
      addTransaction: getIt<AddTransaction>(),
      updateTransaction: getIt<UpdateTransaction>(),
      deleteTransaction: getIt<DeleteTransaction>(),
      repository: getIt<TransactionRepository>(),
    ),
  );

  // Services
  // TODO: Register notification service, analytics service, etc.
}
