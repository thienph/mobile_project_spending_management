import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
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
  late List<GlobalKey> _monthKeys;
  int _selectedMonthIndex = 0; // 0 = this month
  Map<String, double>? _balance; // Cache the balance

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _months = List.generate(12, (i) => DateTime(now.year, now.month - i, 1));
    _monthKeys = List.generate(12, (_) => GlobalKey());
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
    
    // Load balance (in parallel, doesn't affect transaction display)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<TransactionBloc>().add(
              LoadBalanceEvent(
                startDate: _startDate,
                endDate: _endDate,
              ),
            );
      }
    });
  }

  void _filterByType(String type) {
    setState(() => _filterType = type);
    _loadTransactions();
  }

  void _scrollToSelectedMonth(int index) {
    final key = _monthKeys[index];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
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
                hintText: 'Tìm kiếm...',
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
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: 0,
                ),
              ),
            ),
          ),
          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Row(
              children: [
                if (_selectedMonthIndex != 0)
                  Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_double_arrow_left),
                      onPressed: () {
                        setState(() {
                          _selectedMonthIndex = 0;
                          final month = _months[0];
                          _startDate = month.startOfMonth;
                          _endDate = month.endOfMonth;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToSelectedMonth(0);
                        });
                        _loadTransactions();
                      },
                    ),
                  ),
                Expanded(
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
                          key: _monthKeys[index],
                          showCheckmark: false,
                          selected: selected,
                          label: Text(label),
                          onSelected: (value) {
                            if (!value) return;
                            setState(() {
                              _selectedMonthIndex = index;
                              _startDate = month.startOfMonth;
                              _endDate = month.endOfMonth;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToSelectedMonth(index);
                            });
                            _loadTransactions();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Filter SegmentedButton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('Tất cả')),
                  ButtonSegment(value: 'income', label: Text('Thu nhập')),
                  ButtonSegment(value: 'expense', label: Text('Chi tiêu')),
                ],
                selected: {_filterType},
                onSelectionChanged: (Set<String> newSelection) {
                  _filterByType(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundColor,
                  selectedBackgroundColor: _filterType == 'income'
                      ? AppTheme.incomeColor
                      : _filterType == 'expense'
                          ? AppTheme.expenseColor
                          : AppTheme.primaryColor,
                  selectedForegroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Transaction List
          Expanded(
            child: BlocConsumer<TransactionBloc, TransactionState>(
              listener: (context, state) {
                // Cache balance when it's loaded
                if (state is TransactionLoaded && state.balance != null) {
                  setState(() {
                    _balance = state.balance;
                  });
                }
                // Show success messages (transaction changes are auto-reloaded by BLoC)
                if (state is TransactionAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thêm giao dịch thành công')),
                  );
                  _loadTransactions();
                }
                if (state is TransactionDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa giao dịch thành công')),
                  );
                  _loadTransactions();
                }
                if (state is TransactionUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật giao dịch thành công')),
                  );
                  _loadTransactions();
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
                if (state is TransactionLoaded) {
                  final transactions = state.transactions;
                  if (state.balance != null) {
                    _balance = state.balance;
                  }
                  
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
                  return Column(
                    children: [
                      if (_balance != null) _buildBalanceSummary(),
                      Expanded(child: _buildGroupedTransactionList(transactions)),
                    ],
                  );
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

  Widget _buildBalanceSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd, AppTheme.spacingMd),
      child: BalanceSummaryCard(
        openingBalance: _balance!['openingBalance'] ?? 0,
        income: _balance!['income'] ?? 0,
        expense: _balance!['expense'] ?? 0,
        closingBalance: _balance!['closingBalance'] ?? 0,
      ),
    );
  }

  /// Build transaction list grouped by date
  Widget _buildGroupedTransactionList(List<Transaction> transactions) {
    final groupedTransactions = groupBy(
      transactions,
      (Transaction t) => t.date.startOfDay,
    );

    final sortedKeys = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedKeys.length,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      itemBuilder: (context, index) {
        final date = sortedKeys[index];
        final transactionsOnDate = groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingLg, bottom: AppTheme.spacingSm),
              child: Text(
                date.isToday ? 'Hôm nay' : (date.isYesterday ? 'Hôm qua' : date.toDateString()),
                style: const TextStyle(
                  fontWeight: AppTheme.fontWeightSemiBold,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
            ...transactionsOnDate.map((transaction) => _buildTransactionItem(transaction)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == 'income';
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: ListTile(
        leading: CircleAvatar(
          // TODO: Replace with category icon
          child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward),
        ),
        title: Text(
          transaction.description ?? 'Giao dịch không tên',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(transaction.date.toTimeString()), // Or category name
        trailing: Text(
          '${isIncome ? '+' : '-'}${transaction.amount.toCurrency()}',
          style: TextStyle(
            fontWeight: AppTheme.fontWeightSemiBold,
            color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
            fontSize: AppTheme.fontSizeLg,
          ),
        ),
        onTap: () async {
          final result = await context.pushNamed(
            'edit-transaction',
            pathParameters: {'id': transaction.id!.toString()},
            extra: transaction,
          );
          if (result == true && mounted) {
            _loadTransactions();
          }
        },
      ),
    );
  }
}
