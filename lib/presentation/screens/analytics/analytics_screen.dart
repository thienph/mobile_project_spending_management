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

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    context.read<AnalyticsBloc>().add(ChangePeriod(_selectedPeriod));
  }

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

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPeriod = period;
          });
          context.read<AnalyticsBloc>().add(ChangePeriod(period));
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
                    ? AppTheme.incomeColor.withOpacity(0.1)
                    : AppTheme.expenseColor.withOpacity(0.1),
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
          color: color.withOpacity(0.1),
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
                        ).withOpacity(0.2),
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
