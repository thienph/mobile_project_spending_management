import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/date_extensions.dart';
import 'package:mobile_project_spending_management/core/utils/number_extensions.dart';
import 'package:mobile_project_spending_management/domain/entities/daily_summary.dart';

class TrendChart extends StatelessWidget {
  final List<DailySummary> dailySummaries;

  const TrendChart({
    super.key,
    required this.dailySummaries,
  });

  @override
  Widget build(BuildContext context) {
    if (dailySummaries.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có dữ liệu',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      );
    }

    // Find max value for Y axis
    double maxY = 0;
    for (final summary in dailySummaries) {
      if (summary.income > maxY) maxY = summary.income;
      if (summary.expense > maxY) maxY = summary.expense;
    }
    maxY = maxY * 1.2; // Add 20% padding

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (dailySummaries.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final summary = dailySummaries[spot.x.toInt()];
                final label = spot.barIndex == 0 ? 'Thu' : 'Chi';
                final value = spot.barIndex == 0 ? summary.income : summary.expense;
                return LineTooltipItem(
                  '${summary.date.toDateString()}\n$label: ${value.toCurrency()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeXs,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AppTheme.borderColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dailySummaries.length) {
                  return const SizedBox.shrink();
                }

                // Show every nth label to avoid crowding
                final showInterval = (dailySummaries.length / 7).ceil();
                if (index % showInterval != 0 && index != dailySummaries.length - 1) {
                  return const SizedBox.shrink();
                }

                final date = dailySummaries[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeXs,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: maxY / 4,
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
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Income line
          LineChartBarData(
            spots: dailySummaries.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.income);
            }).toList(),
            isCurved: true,
            color: AppTheme.incomeColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.incomeColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.incomeColor.withOpacity(0.1),
            ),
          ),
          // Expense line
          LineChartBarData(
            spots: dailySummaries.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.expense);
            }).toList(),
            isCurved: true,
            color: AppTheme.expenseColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.expenseColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.expenseColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
