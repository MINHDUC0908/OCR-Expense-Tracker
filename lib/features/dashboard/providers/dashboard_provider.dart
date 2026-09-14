// lib/features/dashboard/providers/dashboard_provider.dart
// Riverpod provider managing dashboard statistics and chart data.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../presentation/widgets/bar_chart.dart';
import '../presentation/widgets/donut_chart.dart';

class DashboardData {
  final double grandTotal;
  final double monthTotal;
  final int count;
  final List<DonutChartData> categoryData;
  final List<BarChartDataPoint> weeklyData;

  const DashboardData({
    required this.grandTotal,
    required this.monthTotal,
    required this.count,
    required this.categoryData,
    required this.weeklyData,
  });
}

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  final TransactionRepository _repository = TransactionRepository();

  @override
  Future<DashboardData> build() async {
    return _loadDashboard();
  }

  Future<DashboardData> _loadDashboard() async {
    final now = DateTime.now();

    final grandTotal = await _repository.getGrandTotal();
    final monthTotal = await _repository.getMonthTotal(now);
    final count = await _repository.getCount();
    final categoryTotals = await _repository.getTotalByCategory();
    final dailyTotals = await _repository.getDailyTotals(days: 7);

    // Build Donut data list
    final categoryData = ExpenseCategory.values
        .where((cat) => (categoryTotals[cat] ?? 0) > 0)
        .map((cat) => DonutChartData(
              category: cat,
              amount: categoryTotals[cat] ?? 0.0,
            ))
        .toList();

    // Build 7-day Bar chart points (Mon to Sun of current week)
    final weekDays = DateFormatter.currentWeekDays();
    final weeklyData = weekDays.map((day) {
      final key = DateTime(day.year, day.month, day.day);
      // Find matches on that day
      double amount = 0.0;
      for (final entry in dailyTotals.entries) {
        if (entry.key.year == day.year &&
            entry.key.month == day.month &&
            entry.key.day == day.day) {
          amount += entry.value;
        }
      }

      return BarChartDataPoint(
        label: DateFormatter.weekday(day),
        date: day,
        amount: amount,
      );
    }).toList();

    return DashboardData(
      grandTotal: grandTotal,
      monthTotal: monthTotal,
      count: count,
      categoryData: categoryData,
      weeklyData: weeklyData,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadDashboard());
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(
  DashboardNotifier.new,
);
