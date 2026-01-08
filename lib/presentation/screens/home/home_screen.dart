import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Month Header
            Card(
              color: AppTheme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tháng này',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSizeMd,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      now.toMonthYearString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSizeXxl,
                        fontWeight: AppTheme.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

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
            const SizedBox(height: AppTheme.spacingLg),

            // Quick Actions
            Text(
              'Thao tác nhanh',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pushNamed('add-transaction'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: AppTheme.spacingSm),
                    Text('Thêm giao dịch'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.goNamed('transactions'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: AppTheme.spacingSm),
                    Text('Xem lịch sử giao dịch'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: AppTheme.fontWeightSemiBold,
                  fontSize: AppTheme.fontSizeLg,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeSm,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
