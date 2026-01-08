import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/date_extensions.dart';
import 'package:mobile_project_spending_management/core/utils/number_extensions.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_state.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  String _filterType = 'all'; // 'all', 'income', 'expense'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().startOfDay;
    _endDate = DateTime.now().endOfDay;
    _loadTransactions();
  }

  void _loadTransactions() {
    if (_searchQuery.isNotEmpty) {
      context.read<TransactionBloc>().add(
            SearchTransactionsEvent(
              query: _searchQuery,
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
    } else {
      context.read<TransactionBloc>().add(
            LoadTransactions(
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
    }
  }

  void _filterByType(String type) {
    setState(() => _filterType = type);
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadTransactions();
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giao dịch...',
                filled: true,
                fillColor: AppTheme.backgroundColor,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                          _loadTransactions();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingMd,
                ),
              ),
            ),
          ),
          // Date Range Selector
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                      _loadTransactions();
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Từ ngày', style: TextStyle(fontSize: AppTheme.fontSizeSm)),
                      Text(
                        _startDate.toDateString(),
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          fontWeight: AppTheme.fontWeightSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                      _loadTransactions();
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Đến ngày', style: TextStyle(fontSize: AppTheme.fontSizeSm)),
                      Text(
                        _endDate.toDateString(),
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          fontWeight: AppTheme.fontWeightSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Row(
              children: ['all', 'income', 'expense']
                  .map((type) => Padding(
                        padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                        child: FilterChip(
                          selected: _filterType == type,
                          onSelected: (selected) => _filterByType(type),
                          label: Text(
                            type == 'all' ? 'Tất cả' : (type == 'income' ? 'Thu' : 'Chi'),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Transaction List
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is TransactionError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(state.message),
                        const SizedBox(height: AppTheme.spacingMd),
                        ElevatedButton(
                          onPressed: _loadTransactions,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is TransactionLoaded) {
                  if (state.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textDisabledColor),
                          const SizedBox(height: AppTheme.spacingMd),
                          const Text('Không có giao dịch'),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.transactions.length,
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final transaction = state.transactions[index];
                      final isIncome = transaction.type == 'income';
                      return GestureDetector(
                        onTap: () => context.goNamed(
                          'edit-transaction',
                          extra: transaction,
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingMd),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.description ?? 'Giao dịch không tên',
                                        style: const TextStyle(fontWeight: AppTheme.fontWeightSemiBold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: AppTheme.spacingSm),
                                      Text(
                                        transaction.date.toDateString(),
                                        style: const TextStyle(
                                          fontSize: AppTheme.fontSizeSm,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isIncome ? '+' : '-'}${transaction.amount.toCurrency()}',
                                  style: TextStyle(
                                    fontWeight: AppTheme.fontWeightSemiBold,
                                    color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                                    fontSize: AppTheme.fontSizeLg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
