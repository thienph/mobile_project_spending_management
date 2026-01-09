import 'package:equatable/equatable.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction_summary.dart';
import 'package:mobile_project_spending_management/domain/entities/category_breakdown.dart';
import 'package:mobile_project_spending_management/domain/entities/daily_summary.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final TransactionSummary summary;
  final List<CategoryBreakdown> expenseBreakdown;
  final List<CategoryBreakdown> incomeBreakdown;
  final List<DailySummary> dailySummaries;
  final String period;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsLoaded({
    required this.summary,
    required this.expenseBreakdown,
    required this.incomeBreakdown,
    required this.dailySummaries,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        summary,
        expenseBreakdown,
        incomeBreakdown,
        dailySummaries,
        period,
        startDate,
        endDate,
      ];

  AnalyticsLoaded copyWith({
    TransactionSummary? summary,
    List<CategoryBreakdown>? expenseBreakdown,
    List<CategoryBreakdown>? incomeBreakdown,
    List<DailySummary>? dailySummaries,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AnalyticsLoaded(
      summary: summary ?? this.summary,
      expenseBreakdown: expenseBreakdown ?? this.expenseBreakdown,
      incomeBreakdown: incomeBreakdown ?? this.incomeBreakdown,
      dailySummaries: dailySummaries ?? this.dailySummaries,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
