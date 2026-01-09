import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AnalyticsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String period; // 'day', 'week', 'month', 'year'

  const LoadAnalytics({
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  @override
  List<Object?> get props => [startDate, endDate, period];
}

class ChangePeriod extends AnalyticsEvent {
  final String period; // 'day', 'week', 'month', 'year'

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

class RefreshAnalytics extends AnalyticsEvent {
  const RefreshAnalytics();
}
