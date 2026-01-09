import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_project_spending_management/core/di/injection.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/date_extensions.dart';
import 'package:mobile_project_spending_management/core/utils/number_extensions.dart';
import 'package:mobile_project_spending_management/domain/entities/category.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';
import 'package:mobile_project_spending_management/domain/repositories/category_repository.dart';
import 'package:mobile_project_spending_management/domain/usecases/analytics/get_available_anchors.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_state.dart';
import 'package:mobile_project_spending_management/presentation/widgets/balance_summary_card.dart';
import 'package:mobile_project_spending_management/presentation/widgets/category_transaction_group.dart';

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
  List<DateTime> _months = []; // Month anchors (first day of month)
  List<GlobalKey> _monthKeys = [];
  int _selectedMonthIndex = 0; // 0 = this month
  Map<String, double>? _balance; // Cache the balance
  Map<int, Category> _categoriesCache = {}; // Cache categories

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now.startOfMonth;
    _endDate = now.endOfMonth;
    _loadCategories();
    _loadMonthAnchors();
    _loadTransactions();
  }

  Future<void> _loadCategories() async {
    final categoryRepository = getIt<CategoryRepository>();
    final result = await categoryRepository.getAllCategories();
    result.fold(
      (failure) => null,
      (categories) {
        setState(() {
          _categoriesCache = {for (var cat in categories) cat.id: cat};
        });
      },
    );
  }

  void _loadTransactions() {
    // Load transactions
    if (_searchQuery.isNotEmpty) {
      context.read<TransactionBloc>().add(
            SearchTransactionsEvent(
              query: _searchQuery,
              startDate: _startDate,
              endDate: _endDate,
              filterType: _filterType,
            ),
          );
    } else {
      context.read<TransactionBloc>().add(
            LoadTransactions(
              startDate: _startDate,
              endDate: _endDate,
              filterType: _filterType,
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

  Future<void> _loadMonthAnchors() async {
    final useCase = getIt<GetAvailableAnchors>();
    final result = await useCase(period: 'month');
    result.fold(
      (_) {
        if (!mounted) return;
        setState(() {
          _months = [];
          _monthKeys = [];
          _selectedMonthIndex = 0;
        });
      },
      (anchors) {
        if (!mounted) return;
        setState(() {
          _months = anchors;
          _monthKeys = List.generate(_months.length, (_) => GlobalKey());
          _selectedMonthIndex = 0;
          if (_months.isNotEmpty) {
            final m = _months.first;
            _startDate = m.startOfMonth;
            _endDate = m.endOfMonth;
          }
        });
        _loadTransactions();
      },
    );
  }

  void _showTopBanner(BuildContext context, String message, {bool isError = false}) {
    final screenHeight = MediaQuery.of(context).size.height;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          AppTheme.spacingMd,
          AppTheme.spacingMd,
          AppTheme.spacingMd,
          screenHeight - 150,
        ),
      ),
    );
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
                if (_selectedMonthIndex != 0 && _months.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_double_arrow_left),
                      onPressed: () {
                        setState(() {
                          _selectedMonthIndex = 0;
                          if (_months.isNotEmpty) {
                            final month = _months[0];
                            _startDate = month.startOfMonth;
                            _endDate = month.endOfMonth;
                          }
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
                        String labelForIndex() {
                          final now = DateTime.now();
                          final currentMonthStart = DateTime(now.year, now.month, 1);
                          final prevMonthStart = DateTime(now.year, now.month - 1, 1);
                          final anchorStart = DateTime(month.year, month.month, 1);

                          if (anchorStart == currentMonthStart) return 'Tháng này';
                          if (anchorStart == prevMonthStart) return 'Tháng trước';
                          return month.toMonthYearString();
                        }
                        final label = labelForIndex();
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
                  _showTopBanner(context, 'Thêm giao dịch thành công');
                  _loadTransactions();
                }
                if (state is TransactionDeleted) {
                  _showTopBanner(context, 'Xóa giao dịch thành công');
                  _loadTransactions();
                }
                if (state is TransactionUpdated) {
                  _showTopBanner(context, 'Cập nhật giao dịch thành công');
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

  /// Build transaction list grouped by date and category
  Widget _buildGroupedTransactionList(List<Transaction> transactions) {
    if (_categoriesCache.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Group by date first
    final groupedByDate = groupBy(
      transactions,
      (Transaction t) => t.date.startOfDay,
    );

    final sortedDates = groupedByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final transactionsOnDate = groupedByDate[date]!;

        // Group by category within each date
        final groupedByCategory = groupBy(
          transactionsOnDate,
          (Transaction t) => t.categoryId,
        );

        // Calculate total for the day
        final dayTotal = transactionsOnDate.fold<double>(
          0.0,
          (sum, t) => sum + (t.type == 'income' ? t.amount : -t.amount),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header with total
            Padding(
              padding: const EdgeInsets.only(
                top: AppTheme.spacingLg,
                bottom: AppTheme.spacingSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date.isToday
                        ? 'Hôm nay'
                        : (date.isYesterday ? 'Hôm qua' : date.toDateString()),
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeLg,
                      fontWeight: AppTheme.fontWeightSemiBold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Text(
                    dayTotal >= 0
                        ? '+${dayTotal.toCurrency()}'
                        : dayTotal.toCurrency(),
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMd,
                      fontWeight: AppTheme.fontWeightSemiBold,
                      color: dayTotal >= 0
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor,
                    ),
                  ),
                ],
              ),
            ),
            // Category Groups
            ...groupedByCategory.entries.map((entry) {
              final categoryId = entry.key;
              final categoryTransactions = entry.value;
              final category = _categoriesCache[categoryId];

              if (category == null) {
                return const SizedBox.shrink();
              }

              return CategoryTransactionGroup(
                category: category,
                transactions: categoryTransactions,
                onTransactionChanged: _loadTransactions,
              );
            }),
          ],
        );
      },
    );
  }
}
