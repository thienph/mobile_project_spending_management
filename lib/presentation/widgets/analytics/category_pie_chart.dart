import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/domain/entities/category_breakdown.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategoryBreakdown> breakdowns;

  const CategoryPieChart({
    super.key,
    required this.breakdowns,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.breakdowns.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có dữ liệu',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _getSections(),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: _buildLegend(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getSections() {
    return widget.breakdowns.asMap().entries.map((entry) {
      final index = entry.key;
      final breakdown = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;

      return PieChartSectionData(
        color: Color(int.parse(breakdown.color.replaceFirst('#', '0xFF'))),
        value: breakdown.amount,
        title: '${breakdown.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.breakdowns.length,
      itemBuilder: (context, index) {
        final breakdown = widget.breakdowns[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color:
                      Color(int.parse(breakdown.color.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  breakdown.categoryName,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeXs,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
