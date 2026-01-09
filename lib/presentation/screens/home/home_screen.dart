import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/number_extensions.dart';
import 'package:mobile_project_spending_management/core/utils/date_extensions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thu chi'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Month Header
            _buildBalanceSummaryCard(context, now),
            const Spacer(),

            // Feature Grid
            Text(
              'Tính năng chính',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppTheme.spacingMd,
              crossAxisSpacing: AppTheme.spacingMd,
              children: [
                _FeatureCard(
                  icon: Icons.payment,
                  title: 'Giao dịch',
                  subtitle: 'Quản lý thu/chi',
                  color: AppTheme.primaryColor,
                  onTap: () => context.goNamed('transactions'),
                ),
                _FeatureCard(
                  icon: Icons.analytics,
                  title: 'Phân tích',
                  subtitle: 'Thống kê chi tiêu',
                  color: AppTheme.accentColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng sắp ra mắt')),
                    );
                  },
                ),
                _FeatureCard(
                  icon: Icons.flag,
                  title: 'Mục tiêu',
                  subtitle: 'Tiết kiệm tiền',
                  color: AppTheme.successColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng sắp ra mắt')),
                    );
                  },
                ),
                _FeatureCard(
                  icon: Icons.notifications,
                  title: 'Cảnh báo',
                  subtitle: 'Thông báo chi tiêu',
                  color: AppTheme.warningColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng sắp ra mắt')),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => context.pushNamed('add-transaction'),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.add, size: 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSummaryCard(BuildContext context, DateTime now) {
    // TODO: Replace with actual data from BLoC
    const double income = 5000000;
    const double expense = 2500000;
    final double balance = income - expense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan ${now.toMonthYearString()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Center(
              child: Text(
                balance.toCurrency(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            const Center(
              child: Text('Số dư cuối kỳ'),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            const Divider(),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIncomeExpenseItem('Thu nhập', income, AppTheme.incomeColor),
                _buildIncomeExpenseItem('Chi tiêu', expense, AppTheme.expenseColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseItem(String title, double amount, Color color) {
    return Column(children: [
      Text(title, style: const TextStyle(color: AppTheme.textSecondaryColor)),
      const SizedBox(height: AppTheme.spacingXs),
      Text(amount.toCurrency(), style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: AppTheme.fontSizeLg)),
    ]);
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: AppTheme.fontWeightSemiBold,
                fontSize: AppTheme.fontSizeLg,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondaryColor)),
          ],
        ),
      ),
    );
  }
}
