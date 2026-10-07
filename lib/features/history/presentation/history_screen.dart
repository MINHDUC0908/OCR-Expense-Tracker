// lib/features/history/presentation/history_screen.dart
// Màn hình Lịch sử chi tiêu — hỗ trợ tìm kiếm, lọc, xuất bảng tính CSV cho thủ quỹ & nhập thủ công.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/expense_transaction.dart';
import '../../dashboard/providers/dashboard_provider.dart';
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
        elevation: 0,
        title: Text(
          'Lịch sử chi tiêu',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          // Nút xuất dữ liệu CSV / Bảng tính cho thủ quỹ
          IconButton(
            icon: const Icon(Icons.table_view_rounded, size: 20),
            tooltip: 'Xuất CSV / Bảng tính',
            onPressed: () {
              final state = historyAsync.valueOrNull;
              if (state == null || state.filteredTransactions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chưa có giao dịch nào để xuất bảng tính.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              _showExportCsvDialog(context, state.filteredTransactions);
            },
          ),
          // Nút thêm thủ công (không cần camera)
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            tooltip: 'Nhập thủ công',
            onPressed: () => _showManualAddDialog(context, ref),
          ),
          // Nút làm mới
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Làm mới',
            onPressed: () {
              notifier.refresh();
              ref.read(dashboardProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Text('Lỗi tải lịch sử: $error', style: AppTextStyles.bodySmall),
        ),
        data: (state) {
          return Column(
            children: [
              // Thanh tìm kiếm & lọc
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FilterBar(
                  selectedCategory: state.filter.selectedCategory,
                  onCategoryChanged: notifier.setCategory,
                  onSearchChanged: notifier.setSearchQuery,
                ),
              ),

              // Thống kê nhanh số lượng & tổng tiền của danh sách lọc
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.filteredTransactions.length} giao dịch',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Tổng: ${CurrencyFormatter.formatVnd(state.filteredTransactions.fold<double>(0.0, (sum, t) => sum + t.amount))}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.divider, height: 1),

              // Danh sách giao dịch
              Expanded(
                child: state.filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Không có giao dịch nào',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.filter.selectedCategory != null ||
                                      state.filter.searchQuery.isNotEmpty
                                  ? 'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm'
                                  : 'Quét hóa đơn hoặc bấm (+) để nhập thủ công',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        itemCount: state.filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = state.filteredTransactions[index];
                          return TransactionCard(
                            transaction: tx,
                            onTap: () => _showDetailDialog(context, tx),
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Xoá chi tiêu?',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                  content: Text(
                                    'Bạn có chắc muốn xoá khoản "${tx.merchantName}" (${CurrencyFormatter.formatVnd(tx.amount)}) không?',
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Huỷ', style: TextStyle(fontSize: 12.5)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                      ),
                                      child: const Text('Xoá', style: TextStyle(fontSize: 12.5)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await notifier.deleteTransaction(tx.id);
                                ref.read(dashboardProvider.notifier).refresh();
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

  // Hộp thoại xuất bảng tính CSV cho thủ quỹ câu lạc bộ
  void _showExportCsvDialog(
      BuildContext context, List<ExpenseTransaction> transactions) {
    final buffer = StringBuffer();
    buffer.writeln('Mã giao dịch,Ngày,Cửa hàng / Đơn vị,Danh mục,Số tiền (VNĐ)');

    for (final tx in transactions) {
      final dateStr = DateFormatter.display(tx.date);
      final merchant = tx.merchantName.replaceAll(',', ' ');
      final category = tx.category.displayName;
      final amount = tx.amount.toInt();
      buffer.writeln('${tx.id.substring(0, 8)},$dateStr,$merchant,$category,$amount');
    }

    final csvContent = buffer.toString();
    final totalAmount = transactions.fold<double>(0.0, (sum, t) => sum + t.amount);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.table_chart_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Báo cáo cho thủ quỹ (${transactions.length} mục)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng chi tiêu: ${CurrencyFormatter.formatVnd(totalAmount)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dữ liệu định dạng CSV để dán trực tiếp vào Excel / Google Sheets:',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                height: 140,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csvContent,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: csvContent));
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Đã sao chép bảng tính CSV vào bộ nhớ đệm!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Sao chép CSV', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // Hộp thoại xem chi tiết biên lai
  void _showDetailDialog(BuildContext context, ExpenseTransaction tx) {
    final hasValidImage =
        tx.imagePath != null && File(tx.imagePath!).existsSync();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasValidImage)
                Container(
                  height: 240,
                  color: Colors.black,
                  child: InteractiveViewer(
                    child: Image.file(File(tx.imagePath!), fit: BoxFit.contain),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tx.merchantName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tx.category.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${tx.category.emoji} ${tx.category.displayName}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: tx.category.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.formatVnd(tx.amount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Ngày: ${DateFormatter.display(tx.date)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã chứng từ: ${tx.id.substring(0, 13)}...',
                      style: const TextStyle(fontSize: 10, color: AppColors.textDisabled),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Đóng', style: TextStyle(fontSize: 12.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hộp thoại thêm chi tiêu thủ công
  void _showManualAddDialog(BuildContext context, WidgetRef ref) {
    final amountCtrl = TextEditingController();
    final merchantCtrl = TextEditingController();
    var selectedCategory = ExpenseCategory.food;
    var selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Thêm chi tiêu thủ công',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: merchantCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên cửa hàng / Đơn vị',
                    hintText: 'VD: Siêu thị WinMart, Canteen...',
                    prefixIcon: Icon(Icons.storefront_rounded, size: 18),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền (VNĐ)',
                    hintText: 'VD: 50000',
                    suffixText: 'VNĐ',
                    prefixIcon: Icon(Icons.payments_rounded, size: 18),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                  title: Text(
                    DateFormatter.display(selectedDate),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Text('Danh mục:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ExpenseCategory.values.map((cat) {
                    final isSel = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text('${cat.emoji} ${cat.displayName}'),
                      labelStyle: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                        color: isSel ? cat.color : AppColors.textSecondary,
                      ),
                      selected: isSel,
                      selectedColor: cat.color.withValues(alpha: 0.2),
                      onSelected: (_) => setState(() => selectedCategory = cat),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                final merchant = merchantCtrl.text.trim().isEmpty ? 'Chi tiêu tự nhập' : merchantCtrl.text.trim();

                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
                  );
                  return;
                }

                final newTx = ExpenseTransaction(
                  id: const Uuid().v4(),
                  amount: amount,
                  date: selectedDate,
                  merchantName: merchant,
                  category: selectedCategory,
                  createdAt: DateTime.now(),
                );

                await ref.read(historyProvider.notifier).addTransaction(newTx);
                ref.read(dashboardProvider.notifier).refresh();

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Đã thêm khoản chi thành công!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Lưu', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
