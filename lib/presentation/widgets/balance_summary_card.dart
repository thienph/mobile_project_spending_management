import 'package:flutter/material.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/number_extensions.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double openingBalance;
  final double income;
  final double expense;
  final double closingBalance;

  const BalanceSummaryCard({
    super.key,
    required this.openingBalance,
    required this.income,
    required this.expense,
    required this.closingBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opening Balance
            _BalanceRow(
              label: 'Số dư đầu kỳ',
              amount: openingBalance,
              isOpening: true,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Income & Expense
            Row(
              children: [
                Expanded(
                  child: _BalanceRow(
                    label: 'Thu nhập',
                    amount: income,
                    color: AppTheme.incomeColor,
                    isColumn: true,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _BalanceRow(
                    label: 'Chi tiêu',
                    amount: expense,
                    color: AppTheme.expenseColor,
                    isColumn: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            const Divider(color: Colors.white30),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Closing Balance
            _BalanceRow(
              label: 'Số dư cuối kỳ',
              amount: closingBalance,
              isOpening: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;
  final bool isOpening;
  final bool isColumn;

  const _BalanceRow({
    required this.label,
    required this.amount,
    this.color,
    this.isOpening = false,
    this.isColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Colors.white;
    
    if (isColumn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: AppTheme.fontSizeSm,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            amount.toCurrency(),
            style: TextStyle(
              color: textColor,
              fontSize: AppTheme.fontSizeLg,
              fontWeight: AppTheme.fontWeightSemiBold,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: AppTheme.fontSizeMd,
          ),
        ),
        Text(
          amount.toCurrency(),
          style: TextStyle(
            color: textColor,
            fontSize: AppTheme.fontSizeLg,
            fontWeight: AppTheme.fontWeightSemiBold,
          ),
        ),
      ],
    );
  }
}
