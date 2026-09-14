// lib/core/utils/date_formatter.dart
// Utility for formatting and parsing dates.

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy', 'vi');
  static final DateFormat _shortFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dbFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy', 'vi');
  static final DateFormat _dayFormat = DateFormat('EEE', 'vi');

  /// Formats [date] for display: e.g. "11 Sep 2026"
  static String display(DateTime date) => _displayFormat.format(date);

  /// Formats [date] in short VN form: e.g. "11/09/2026"
  static String short(DateTime date) => _shortFormat.format(date);

  /// Formats [date] for DB storage: "2026-09-11"
  static String toDb(DateTime date) => _dbFormat.format(date);

  /// Parses a DB date string back to [DateTime].
  static DateTime fromDb(String value) => _dbFormat.parse(value);

  /// Formats [date] as month-year: "Sep 2026"
  static String monthYear(DateTime date) => _monthYearFormat.format(date);

  /// Short weekday abbreviation for bar chart labels: "Mon", "Tue", ...
  static String weekday(DateTime date) => _dayFormat.format(date);

  /// Returns the start of the week (Monday) for the given [date].
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday; // 1=Mon, 7=Sun
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Returns a list of 7 [DateTime]s representing the current week (Mon–Sun).
  static List<DateTime> currentWeekDays() {
    final today = DateTime.now();
    final monday = startOfWeek(today);
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }
}
