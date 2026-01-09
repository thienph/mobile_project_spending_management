import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/number_extensions.dart';
import 'package:mobile_project_spending_management/domain/entities/category_breakdown.dart';
import 'package:mobile_project_spending_management/presentation/bloc/analytics/analytics_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/analytics/analytics_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/analytics/analytics_state.dart';
import 'package:mobile_project_spending_management/presentation/widgets/analytics/income_expense_chart.dart';
import 'package:mobile_project_spending_management/presentation/widgets/analytics/category_pie_chart.dart';
import 'package:mobile_project_spending_management/presentation/widgets/analytics/trend_chart.dart';
import 'package:mobile_project_spending_management/core/di/injection.dart';
import 'package:mobile_project_spending_management/domain/usecases/analytics/get_available_anchors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'week';
  DateTime _focusedDate = DateTime.now();
  List<DateTime> _periodAnchors = [];
  List<GlobalKey> _anchorKeys = [];
  int _selectedAnchorIndex = 0; // 0 = current period

  @override
  void initState() {
    super.initState();
    _loadAnchors();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final range = _calculateDateRange(_selectedPeriod, _focusedDate);
    context.read<AnalyticsBloc>().add(LoadAnalytics(
          startDate: range.start,
          endDate: range.end,
          period: _selectedPeriod,
        ));
  }

  Future<void> _loadAnchors() async {
    final useCase = getIt<GetAvailableAnchors>();
    final result = await useCase(period: _selectedPeriod);
    result.fold(
      (_) {
        setState(() {
          _periodAnchors = [];
          _anchorKeys = [];
          _selectedAnchorIndex = 0;
        });
      },
      (anchors) {
        setState(() {
          _periodAnchors = anchors;
          _anchorKeys = List.generate(_periodAnchors.length, (_) => GlobalKey());
          _selectedAnchorIndex = 0;
          _focusedDate = _periodAnchors.isNotEmpty ? _periodAnchors.first : DateTime.now();
        });
      },
    );
  }

  void _scrollToSelectedAnchor(int index) {
    if (index < 0 || index >= _anchorKeys.length) return;
    final key = _anchorKeys[index];
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

  // Removed local week helper; repository computes anchors by data

  ({DateTime start, DateTime end}) _calculateDateRange(
      String period, DateTime date) {
    DateTime start;
    DateTime end;

    switch (period) {
      case 'week':
        start = date.subtract(Duration(days: date.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        end = start.add(
            const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case 'month':
        start = DateTime(date.year, date.month, 1);
        final nextMonth = DateTime(date.year, date.month + 1, 1);
        end = nextMonth.subtract(const Duration(seconds: 1));
        break;
      case 'year':
        start = DateTime(date.year, 1, 1);
        end = DateTime(date.year, 12, 31, 23, 59, 59);
        break;
      default:
        start = DateTime(date.year, date.month, date.day);
        end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    }
    return (start: start, end: end);
  }

  // Removed chevron navigator; using horizontal anchor list

  // Removed text label builder; labels now derive per anchor chip

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Phân tích'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AnalyticsBloc>().add(const RefreshAnalytics());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _buildPeriodAnchorList(),
          Expanded(
            child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AnalyticsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: AppTheme.errorColor),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'Lỗi: ${state.message}',
                          style: const TextStyle(color: AppTheme.errorColor),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        ElevatedButton(
                          onPressed: _loadAnalytics,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AnalyticsLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<AnalyticsBloc>()
                          .add(const RefreshAnalytics());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(state),
                          const SizedBox(height: AppTheme.spacingLg),
                          _buildIncomeExpenseChart(state),
                          const SizedBox(height: AppTheme.spacingLg),
                          _buildTrendChart(state),
                          const SizedBox(height: AppTheme.spacingLg),
                          _buildCategoryPieChart(
                            'Chi tiêu theo danh mục',
                            state.expenseBreakdown,
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
                          _buildCategoryPieChart(
                            'Thu nhập theo danh mục',
                            state.incomeBreakdown,
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
                          _buildTopCategories(state),
                        ],
                      ),
                    ),
                  );
                }

                return const Center(
                  child: Text('Chưa có dữ liệu phân tích'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Tuần', 'week'),
          const SizedBox(width: AppTheme.spacingSm),
          _buildPeriodButton('Tháng', 'month'),
          const SizedBox(width: AppTheme.spacingSm),
          _buildPeriodButton('Năm', 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodAnchorList() {
    if (_periodAnchors.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
        color: Colors.white,
        alignment: Alignment.centerLeft,
        child: const Text(
          'Không có dữ liệu kỳ hạn',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      );
    }
    String labelForIndex(int index) {
      final anchor = _periodAnchors[index];
      final now = DateTime.now();
      final currentRange = _calculateDateRange(_selectedPeriod, now);
      final range = _calculateDateRange(_selectedPeriod, anchor);

      String formatDate(DateTime d) =>
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

      // Current and previous labels
      if (range.start.year == currentRange.start.year &&
          range.start.month == currentRange.start.month &&
          range.start.day == currentRange.start.day) {
        switch (_selectedPeriod) {
          case 'week':
            return 'Tuần này';
          case 'month':
            return 'Tháng này';
          case 'year':
            return 'Năm nay';
        }
      }

      final previousDate = _selectedPeriod == 'week'
          ? now.subtract(const Duration(days: 7))
          : _selectedPeriod == 'month'
              ? DateTime(now.year, now.month - 1, 1)
              : DateTime(now.year - 1, 1, 1);
      final previousRange = _calculateDateRange(_selectedPeriod, previousDate);
      if (range.start.year == previousRange.start.year &&
          range.start.month == previousRange.start.month &&
          range.start.day == previousRange.start.day) {
        switch (_selectedPeriod) {
          case 'week':
            return 'Tuần trước';
          case 'month':
            return 'Tháng trước';
          case 'year':
            return 'Năm trước';
        }
      }

      // Default labels
      switch (_selectedPeriod) {
        case 'week':
          return '${formatDate(range.start)} - ${formatDate(range.end)}';
        case 'month':
          return '${range.start.month}/${range.start.year}';
        case 'year':
          return '${range.start.year}';
        default:
          return formatDate(range.start);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
      color: Colors.white,
      child: Row(
        children: [
          if (_selectedAnchorIndex != 0)
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingSm),
              child: IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_left),
                onPressed: () {
                  setState(() {
                    _selectedAnchorIndex = 0;
                    if (_periodAnchors.isNotEmpty) {
                      _focusedDate = _periodAnchors[0];
                    }
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToSelectedAnchor(0);
                  });
                  _loadAnalytics();
                },
              ),
            ),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _periodAnchors.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppTheme.spacingSm),
                itemBuilder: (context, index) {
                  final selected = index == _selectedAnchorIndex;
                  final label = labelForIndex(index);
                  return ChoiceChip(
                    key: _anchorKeys[index],
                    showCheckmark: false,
                    selected: selected,
                    label: Text(label),
                    onSelected: (value) {
                      if (!value) return;
                      setState(() {
                        _selectedAnchorIndex = index;
                        _focusedDate = _periodAnchors[index];
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToSelectedAnchor(index);
                      });
                      _loadAnalytics();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          if (_selectedPeriod != period) {
            setState(() {
              _selectedPeriod = period;
              _focusedDate = DateTime.now();
              // Load anchors based on database data
            });
            _loadAnchors();
            _loadAnalytics();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
          foregroundColor:
              isSelected ? Colors.white : AppTheme.textSecondaryColor,
          elevation: isSelected ? AppTheme.elevationLow : 0,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildSummaryCard(AnalyticsLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: state.summary.balance >= 0
                  ? AppTheme.incomeColor.withValues(alpha: 0.1)
                  : AppTheme.expenseColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Số dư',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLg,
                      fontWeight: AppTheme.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    state.summary.balance.toCurrency(),
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeXxl,
                      fontWeight: AppTheme.fontWeightBold,
                      color: state.summary.balance >= 0
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              children: [
                _buildSummaryItem(
                  'Thu nhập',
                  state.summary.totalIncome,
                  AppTheme.incomeColor,
                  Icons.arrow_upward,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                _buildSummaryItem(
                  'Chi tiêu',
                  state.summary.totalExpense,
                  AppTheme.expenseColor,
                  Icons.arrow_downward,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Center(
              child: Text(
                '${state.summary.transactionCount} giao dịch',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: AppTheme.fontSizeSm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeSm,
                    color: color,
                    fontWeight: AppTheme.fontWeightMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              amount.toCurrency(),
              style: TextStyle(
                fontSize: AppTheme.fontSizeLg,
                fontWeight: AppTheme.fontWeightBold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseChart(AnalyticsLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'So sánh Thu - Chi',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLg,
                fontWeight: AppTheme.fontWeightSemiBold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            SizedBox(
              height: 200,
              child: IncomeExpenseChart(
                income: state.summary.totalIncome,
                expense: state.summary.totalExpense,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(AnalyticsLoaded state) {
    if (state.dailySummaries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xu hướng',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLg,
                fontWeight: AppTheme.fontWeightSemiBold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            SizedBox(
              height: 200,
              child: TrendChart(dailySummaries: state.dailySummaries),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(String title, List<CategoryBreakdown> breakdowns) {
    if (breakdowns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeLg,
                fontWeight: AppTheme.fontWeightSemiBold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            SizedBox(
              height: 250,
              child: CategoryPieChart(breakdowns: breakdowns),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategories(AnalyticsLoaded state) {
    final topExpenses = state.expenseBreakdown.take(5).toList();

    if (topExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top chi tiêu',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLg,
                fontWeight: AppTheme.fontWeightSemiBold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ...topExpenses.map((breakdown) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(breakdown.color.replaceFirst('#', '0xFF')),
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Center(
                        child: Text(
                          breakdown.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            breakdown.categoryName,
                            style: const TextStyle(
                              fontWeight: AppTheme.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '${breakdown.transactionCount} giao dịch',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeSm,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          breakdown.amount.toCurrency(),
                          style: const TextStyle(
                            fontWeight: AppTheme.fontWeightBold,
                            color: AppTheme.expenseColor,
                          ),
                        ),
                        Text(
                          '${breakdown.percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeSm,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
