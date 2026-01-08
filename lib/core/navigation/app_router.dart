import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_project_spending_management/core/di/injection.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:mobile_project_spending_management/presentation/screens/home/home_screen.dart';
import 'package:mobile_project_spending_management/presentation/screens/transactions/transaction_list_screen.dart';
import 'package:mobile_project_spending_management/presentation/screens/transactions/add_transaction_screen.dart';

class AppRouter {
  static GoRouter router = GoRouter(
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
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<TransactionBloc>(),
          child: const AddTransactionScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
