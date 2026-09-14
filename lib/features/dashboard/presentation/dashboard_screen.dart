// lib/features/dashboard/presentation/dashboard_screen.dart
// Main Dashboard screen with summary cards, Donut Chart, and Weekly Bar Chart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/bar_chart.dart';
import 'widgets/donut_chart.dart';
import 'widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text('Failed to load dashboard', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 6),
                Text(error.toString(), style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Overview Summary Card
                  SummaryCard(
                    grandTotal: data.grandTotal,
                    monthTotal: data.monthTotal,
                    transactionCount: data.count,
                  ),

                  const SizedBox(height: 24),

                  // Section 1: Category Distribution Donut Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Spending by Category',
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 20),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DonutChart(
                            data: data.categoryData,
                            totalAmount: data.grandTotal,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 2: Weekly Spending Bar Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'This Week Spending',
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          WeeklyBarChart(
                            weeklyData: data.weeklyData,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Action: Scan Receipt Button
                  ElevatedButton.icon(
                    onPressed: () => context.push('/camera'),
                    icon: const Icon(Icons.document_scanner_rounded),
                    label: const Text('Scan New Receipt'),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
