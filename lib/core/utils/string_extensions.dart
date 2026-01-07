extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Validate if string is not empty or null
  bool get isNotNullOrEmpty {
    return trim().isNotEmpty;
  }

  /// Remove all whitespace
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string is a valid number
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Parse to double or return 0
  double toDoubleOrZero() {
    return double.tryParse(this) ?? 0.0;
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
