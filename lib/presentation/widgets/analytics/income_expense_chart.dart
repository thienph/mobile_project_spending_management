import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/number_extensions.dart';

class IncomeExpenseChart extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpenseChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = income > expense ? income : expense;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue > 0 ? maxValue * 1.2 : 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = rod.toY;
              final label = groupIndex == 0 ? 'Thu nhập' : 'Chi tiêu';
              return BarTooltipItem(
                '$label\n${value.toCurrency()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Thu nhập',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeSm,
                          fontWeight: AppTheme.fontWeightMedium,
                        ),
                      ),
                    );
                  case 1:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Chi tiêu',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeSm,
                          fontWeight: AppTheme.fontWeightMedium,
                        ),
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toCompactCurrency(),
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeXs,
                    color: AppTheme.textSecondaryColor,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue > 0 ? maxValue / 4 : 25,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AppTheme.borderColor,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: income,
                color: AppTheme.incomeColor,
                width: 40,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusSm),
                  topRight: Radius.circular(AppTheme.radiusSm),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: expense,
                color: AppTheme.expenseColor,
                width: 40,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusSm),
                  topRight: Radius.circular(AppTheme.radiusSm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
