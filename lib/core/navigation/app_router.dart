import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_project_spending_management/core/di/injection.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/categories/category_bloc.dart';
import 'package:mobile_project_spending_management/presentation/screens/home/home_screen.dart';
import 'package:mobile_project_spending_management/presentation/screens/transactions/transaction_list_screen.dart';
import 'package:mobile_project_spending_management/presentation/screens/transactions/add_transaction_screen.dart';
import 'package:mobile_project_spending_management/presentation/screens/transactions/edit_transaction_screen.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<TransactionBloc>(),
          child: const TransactionListScreen(),
        ),
      ),
      GoRoute(
        path: '/transactions/add',
        name: 'add-transaction',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<TransactionBloc>()),
            BlocProvider(create: (_) => getIt<CategoryBloc>()),
          ],
          child: const AddTransactionScreen(),
        ),
      ),
      GoRoute(
        path: '/transactions/edit/:id',
        name: 'edit-transaction',
        builder: (context, state) {
          final transaction = state.extra as Transaction?;
          if (transaction == null) {
            return const Scaffold(
              body: Center(child: Text('Giao dịch không tìm thấy')),
            );
          }
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<TransactionBloc>()),
              BlocProvider(create: (_) => getIt<CategoryBloc>()),
            ],
            child: EditTransactionScreen(transaction: transaction),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
