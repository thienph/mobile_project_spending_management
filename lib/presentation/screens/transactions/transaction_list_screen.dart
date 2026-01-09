import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/date_extensions.dart';
import 'package:mobile_project_spending_management/core/utils/number_extensions.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_state.dart';
import 'package:mobile_project_spending_management/presentation/widgets/balance_summary_card.dart';

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
  late List<DateTime> _months; // Month anchors (first day of month)
  int _selectedMonthIndex = 0; // 0 = this month
  Map<String, double>? _balance; // Cache the balance
  List<Transaction> _transactions = []; // Cache transactions

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _months = List.generate(12, (i) => DateTime(now.year, now.month - i, 1));
    _startDate = now.startOfMonth;
    _endDate = now.endOfMonth;
    _loadTransactions();
  }

  void _loadTransactions() {
    // Load transactions
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
    
    // Load balance
    context.read<TransactionBloc>().add(
          LoadBalanceEvent(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
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
          onPressed: () => context.goNamed('home'),
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
          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _months.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppTheme.spacingSm),
                itemBuilder: (context, index) {
                  final month = _months[index];
                  final label = index == 0
                      ? 'Tháng này'
                      : index == 1
                          ? 'Tháng trước'
                          : month.toMonthYearString();
                  final selected = index == _selectedMonthIndex;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(label),
                    onSelected: (value) {
                      if (!value) return;
                      setState(() {
                        _selectedMonthIndex = index;
                        _startDate = month.startOfMonth;
                        _endDate = month.endOfMonth;
                      });
                      _loadTransactions();
                    },
                  );
                },
              ),
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
            child: BlocConsumer<TransactionBloc, TransactionState>(
              listener: (context, state) {
                // Cache transactions when loaded
                if (state is TransactionLoaded) {
                  setState(() {
                    _transactions = state.transactions;
                  });
                }
                // Cache balance when it's loaded
                if (state is BalanceLoaded) {
                  setState(() {
                    _balance = state.balance;
                  });
                }
                // Show success messages (transaction changes are auto-reloaded by BLoC)
                if (state is TransactionAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thêm giao dịch thành công')),
                  );
                }
                if (state is TransactionDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa giao dịch thành công')),
                  );
                }
                if (state is TransactionUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật giao dịch thành công')),
                  );
                }
              },
              builder: (context, state) {
                // Show loading
                if (state is TransactionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                // Show error
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
                
                // Show transactions (from cache or state)
                if (state is TransactionLoaded || _transactions.isNotEmpty) {
                  final transactions = state is TransactionLoaded ? state.transactions : _transactions;
                  if (transactions.isEmpty) {
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
                  
                  // Build transaction list with balance summary
                  return _buildTransactionList(transactions);
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.pushNamed('add-transaction');
          if (result == true && mounted) {
            _loadTransactions();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build transaction list with balance summary
  Widget _buildTransactionList(List<Transaction> transactions) {
    return ListView.builder(
      itemCount: transactions.length + (_balance != null ? 1 : 0),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      itemBuilder: (context, index) {
        // Show balance summary at top
        if (_balance != null && index == 0) {
          return BalanceSummaryCard(
            openingBalance: _balance!['openingBalance'] ?? 0,
            income: _balance!['income'] ?? 0,
            expense: _balance!['expense'] ?? 0,
            closingBalance: _balance!['closingBalance'] ?? 0,
          );
        }

        final transactionIndex = _balance != null ? index - 1 : index;
        final transaction = transactions[transactionIndex];
        final isIncome = transaction.type == 'income';
        
        return InkWell(
          onTap: () async {
            final result = await context.pushNamed(
              'edit-transaction',
              pathParameters: {
                'id': transaction.id!.toString(),
              },
              extra: transaction,
            );
            if (result == true && mounted) {
              _loadTransactions();
            }
          },
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
                  const SizedBox(width: AppTheme.spacingMd),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}${transaction.amount.toCurrency()}',
                        style: TextStyle(
                          fontWeight: AppTheme.fontWeightSemiBold,
                          color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                          fontSize: AppTheme.fontSizeLg,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
