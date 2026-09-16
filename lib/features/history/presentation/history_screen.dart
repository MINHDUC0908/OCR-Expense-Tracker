// lib/features/history/presentation/history_screen.dart
// Màn hình Lịch sử chi tiêu bằng tiếng Việt

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/history_provider.dart';
import 'widgets/filter_bar.dart';
import 'widgets/transaction_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Lịch sử chi tiêu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Text('Lỗi tải lịch sử: $error'),
        ),
        data: (state) {
          return Column(
            children: [
              // Thanh tìm kiếm & lọc
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: FilterBar(
                  selectedCategory: state.filter.selectedCategory,
                  onCategoryChanged: notifier.setCategory,
                  onSearchChanged: notifier.setSearchQuery,
                ),
              ),

              Container(
                height: 1,
                color: AppColors.divider,
              ),

              // Danh sách giao dịch
              Expanded(
                child: state.filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy giao dịch',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              state.filter.selectedCategory != null ||
                                      state.filter.searchQuery.isNotEmpty
                                  ? 'Thử thay đổi bộ lọc'
                                  : 'Quét hóa đơn đầu tiên để bắt đầu',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: state.filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = state.filteredTransactions[index];
                          return TransactionCard(
                            transaction: tx,
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text('Xoá chi tiêu?'),
                                  content: Text(
                                    'Bạn có chắc muốn xoá "${tx.merchantName}" không?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Huỷ'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                      ),
                                      child: const Text('Xoá'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await notifier.deleteTransaction(tx.id);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
