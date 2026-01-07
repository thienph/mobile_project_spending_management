import 'package:intl/intl.dart';
import 'package:mobile_project_spending_management/core/constants/app_constants.dart';

extension DateTimeExtensions on DateTime {
  /// Format date as dd/MM/yyyy
  String toDateString() {
    return DateFormat(AppConstants.dateFormat).format(this);
  }

  /// Format date as dd/MM/yyyy HH:mm
  String toDateTimeString() {
    return DateFormat(AppConstants.dateTimeFormat).format(this);
  }

  /// Format date as MM/yyyy
  String toMonthYearString() {
    return DateFormat(AppConstants.monthYearFormat).format(this);
  }

  /// Format time as HH:mm
  String toTimeString() {
    return DateFormat(AppConstants.timeFormat).format(this);
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is in current month
  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  /// Get end of year
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  /// Get relative time string (Hôm nay, Hôm qua, etc.)
  String toRelativeString() {
    if (isToday) return 'Hôm nay';
    if (isYesterday) return 'Hôm qua';
    return toDateString();
  }
}
