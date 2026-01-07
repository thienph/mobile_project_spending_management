// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Quản lý Thu Chi';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'spending_management.db';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String monthYearFormat = 'MM/yyyy';
  static const String timeFormat = 'HH:mm';

  // Currency
  static const String currencySymbol = '₫';
  static const String currencyCode = 'VND';
  static const String currencyFormat = '#,###';

  // Transaction Types
  static const String typeIncome = 'income';
  static const String typeExpense = 'expense';

  // Budget Alert Thresholds
  static const int defaultAlertThreshold = 80; // 80%
  static const int warningThreshold = 90; // 90%

  // Recurring Frequencies
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyMonthly = 'monthly';
  static const String frequencyYearly = 'yearly';

  // Chart Constants
  static const int maxChartDataPoints = 30;
  static const int defaultChartDays = 7;

  // Pagination
  static const int defaultPageSize = 20;

  // Validation
  static const int maxDescriptionLength = 500;
  static const int maxCategoryNameLength = 100;
  static const int maxGoalNameLength = 200;
  static const double minAmount = 0.01;
  static const double maxAmount = 999999999999.99;
}
