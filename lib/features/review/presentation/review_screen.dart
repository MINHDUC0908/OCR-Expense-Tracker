// lib/features/review/presentation/review_screen.dart
// Màn hình xác nhận, kiểm tra và chỉnh sửa thông tin hóa đơn quét được.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/review_provider.dart';
import 'widgets/editable_field_card.dart';
import 'widgets/receipt_image_viewer.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const ReviewScreen({super.key, required this.imagePath});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _merchantController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider(widget.imagePath));
    final notifier = ref.read(reviewProvider(widget.imagePath).notifier);

    // Đồng bộ controller khi nhận diện OCR xong
    ref.listen(reviewProvider(widget.imagePath), (prev, next) {
      if (prev?.isOcrLoading == true && !next.isOcrLoading) {
        if (_amountController.text.isEmpty && next.amount > 0) {
          _amountController.text = next.amount.toInt().toString();
        }
        if (_merchantController.text.isEmpty && next.merchantName.isNotEmpty) {
          _merchantController.text = next.merchantName;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận hóa đơn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isOcrLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 20),
                  Text(
                    'Đang trích xuất dữ liệu hóa đơn...',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Xem ảnh hóa đơn + dữ liệu OCR
                  ReceiptImageViewer(
                    imagePath: state.imagePath,
                    rawText: state.parsedReceipt?.rawText ?? '',
                    confidence: state.parsedReceipt?.confidence ?? 0.0,
                    processingTimeMs: state.parsedReceipt?.processingTimeMs ?? 0,
                  ),

                  const SizedBox(height: 20),

                  // Nhập tổng tiền
                  EditableFieldCard(
                    label: 'TỔNG SỐ TIỀN (VNĐ)',
                    icon: Icons.payments_outlined,
                    helperText: state.amount > 0
                        ? 'Định dạng: ${CurrencyFormatter.formatVnd(state.amount)}'
                        : 'Nhập số tiền đã thanh toán',
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        suffixText: 'VNĐ',
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                        notifier.updateAmount(parsed);
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Nhập tên nơi bán / cửa hàng
                  EditableFieldCard(
                    label: 'TÊN CỬA HÀNG / DỊCH VỤ',
                    icon: Icons.storefront_outlined,
                    child: TextField(
                      controller: _merchantController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'VD: Highlands Coffee, Siêu thị WinMart...',
                      ),
                      onChanged: notifier.updateMerchant,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Chọn ngày giao dịch
                  EditableFieldCard(
                    label: 'NGÀY GIAO DỊCH',
                    icon: Icons.calendar_today_outlined,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: state.date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  surface: AppColors.surface,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          notifier.updateDate(picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormatter.display(state.date),
                              style: AppTextStyles.bodyLarge,
                            ),
                            const Icon(Icons.edit_calendar_rounded, size: 20, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Chọn danh mục chi tiêu
                  EditableFieldCard(
                    label: 'DANH MỤC CHI TIÊU',
                    icon: Icons.category_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ExpenseCategory.values.map((cat) {
                        final isSelected = state.category == cat;
                        return ChoiceChip(
                          avatar: Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                          label: Text(cat.displayName),
                          selected: isSelected,
                          selectedColor: cat.color.withValues(alpha: 0.22),
                          side: BorderSide(
                            color: isSelected ? cat.color : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? cat.color : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          onSelected: (_) => notifier.updateCategory(cat),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Nút hành động
                  ElevatedButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            final success = await notifier.saveTransaction();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã lưu chi tiêu thành công!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              context.go('/');
                            }
                          },
                    icon: state.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(state.isSaving ? 'Đang lưu...' : 'Lưu chi tiêu'),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: state.isSaving ? null : () => context.pop(),
                    child: const Text('Hủy bỏ'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
