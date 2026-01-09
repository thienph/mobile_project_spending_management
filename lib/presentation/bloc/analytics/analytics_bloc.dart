import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_project_spending_management/domain/usecases/analytics/get_transaction_summary.dart';
import 'package:mobile_project_spending_management/domain/usecases/analytics/get_category_breakdown.dart';
import 'package:mobile_project_spending_management/domain/usecases/analytics/get_daily_summaries.dart';
import 'package:mobile_project_spending_management/presentation/bloc/analytics/analytics_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/analytics/analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetTransactionSummary getTransactionSummary;
  final GetCategoryBreakdown getCategoryBreakdown;
  final GetDailySummaries getDailySummaries;

  AnalyticsBloc({
    required this.getTransactionSummary,
    required this.getCategoryBreakdown,
    required this.getDailySummaries,
  }) : super(const AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<ChangePeriod>(_onChangePeriod);
    on<RefreshAnalytics>(_onRefreshAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());

    try {
      // Fetch all data in parallel
      final summaryResult = await getTransactionSummary(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final expenseBreakdownResult = await getCategoryBreakdown(
        startDate: event.startDate,
        endDate: event.endDate,
        type: 'expense',
      );

      final incomeBreakdownResult = await getCategoryBreakdown(
        startDate: event.startDate,
        endDate: event.endDate,
        type: 'income',
      );

      final dailySummariesResult = await getDailySummaries(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      // Check for failures
      if (summaryResult.isLeft()) {
        summaryResult.fold(
          (failure) => emit(AnalyticsError(failure.message)),
          (_) => null,
        );
        return;
      }

      if (expenseBreakdownResult.isLeft()) {
        expenseBreakdownResult.fold(
          (failure) => emit(AnalyticsError(failure.message)),
          (_) => null,
        );
        return;
      }

      if (incomeBreakdownResult.isLeft()) {
        incomeBreakdownResult.fold(
          (failure) => emit(AnalyticsError(failure.message)),
          (_) => null,
        );
        return;
      }

      if (dailySummariesResult.isLeft()) {
        dailySummariesResult.fold(
          (failure) => emit(AnalyticsError(failure.message)),
          (_) => null,
        );
        return;
      }

      // Extract values
      final summary = summaryResult.getOrElse(() => throw Exception());
      final expenseBreakdown =
          expenseBreakdownResult.getOrElse(() => throw Exception());
      final incomeBreakdown =
          incomeBreakdownResult.getOrElse(() => throw Exception());
      final dailySummaries =
          dailySummariesResult.getOrElse(() => throw Exception());

      emit(AnalyticsLoaded(
        summary: summary,
        expenseBreakdown: expenseBreakdown,
        incomeBreakdown: incomeBreakdown,
        dailySummaries: dailySummaries,
        period: event.period,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<AnalyticsState> emit,
  ) async {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (event.period) {
      case 'day':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    add(LoadAnalytics(
      startDate: startDate,
      endDate: endDate,
      period: event.period,
    ));
  }

  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (state is AnalyticsLoaded) {
      final currentState = state as AnalyticsLoaded;
      add(LoadAnalytics(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        period: currentState.period,
      ));
    } else {
      // Default to current month
      final now = DateTime.now();
      add(LoadAnalytics(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
        period: 'month',
      ));
    }
  }
}
