import 'package:intl/intl.dart';
import 'package:mobile_project_spending_management/core/constants/app_constants.dart';

extension DoubleExtensions on double {
  /// Format as currency (₫ #,###)
  String toCurrency() {
    final formatter = NumberFormat(AppConstants.currencyFormat, 'vi_VN');
    return '${formatter.format(this)} ${AppConstants.currencySymbol}';
  }

  /// Format as currency without symbol (#,###)
  String toCurrencyWithoutSymbol() {
    final formatter = NumberFormat(AppConstants.currencyFormat, 'vi_VN');
    return formatter.format(this);
  }

  /// Format as compact currency (1K, 1M, 1B)
  String toCompactCurrency() {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B ${AppConstants.currencySymbol}';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M ${AppConstants.currencySymbol}';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K ${AppConstants.currencySymbol}';
    }
    return toCurrency();
  }

  /// Format as percentage (80%)
  String toPercentage({int decimals = 0}) {
    return '${toStringAsFixed(decimals)}%';
  }

  /// Check if amount is valid
  bool get isValidAmount {
    return this >= AppConstants.minAmount && this <= AppConstants.maxAmount;
  }
}

extension IntExtensions on int {
  /// Format as currency
  String toCurrency() {
    return toDouble().toCurrency();
  }

  /// Format as compact currency
  String toCompactCurrency() {
    return toDouble().toCompactCurrency();
  }

  /// Format as percentage
  String toPercentage({int decimals = 0}) {
    return toDouble().toPercentage(decimals: decimals);
  }
}
