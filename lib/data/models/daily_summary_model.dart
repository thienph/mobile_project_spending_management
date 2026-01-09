import 'package:mobile_project_spending_management/domain/entities/daily_summary.dart';

class DailySummaryModel extends DailySummary {
  const DailySummaryModel({
    required super.date,
    required super.income,
    required super.expense,
    required super.balance,
  });

  factory DailySummaryModel.fromEntity(DailySummary entity) {
    return DailySummaryModel(
      date: entity.date,
      income: entity.income,
      expense: entity.expense,
      balance: entity.balance,
    );
  }

  DailySummary toEntity() {
    return DailySummary(
      date: date,
      income: income,
      expense: expense,
      balance: balance,
    );
  }
}
