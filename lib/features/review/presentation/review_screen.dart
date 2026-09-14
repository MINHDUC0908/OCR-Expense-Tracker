// lib/features/review/presentation/review_screen.dart
// Screen for reviewing, verifying, and editing OCR-extracted fields before storing.

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

    // Sync controllers when OCR completes
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
        title: const Text('Review Receipt'),
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
                    'Extracting receipt data on-device...',
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
                  // Receipt Image + OCR Inspection View
                  ReceiptImageViewer(
                    imagePath: state.imagePath,
                    rawText: state.parsedReceipt?.rawText ?? '',
                    confidence: state.parsedReceipt?.confidence ?? 0.0,
                  ),

                  const SizedBox(height: 24),

                  // Total Amount Input
                  EditableFieldCard(
                    label: 'TOTAL AMOUNT (VND)',
                    icon: Icons.payments_outlined,
                    helperText: state.amount > 0
                        ? 'Formatted: ${CurrencyFormatter.formatVnd(state.amount)}'
                        : 'Enter the final sum paid',
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        suffixText: 'VND',
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                        notifier.updateAmount(parsed);
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Merchant Name Input
                  EditableFieldCard(
                    label: 'MERCHANT / STORE NAME',
                    icon: Icons.storefront_outlined,
                    child: TextField(
                      controller: _merchantController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Highlands Coffee',
                      ),
                      onChanged: notifier.updateMerchant,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Transaction Date Selector
                  EditableFieldCard(
                    label: 'TRANSACTION DATE',
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
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary,
                                  onPrimary: AppColors.background,
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
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

                  // Expense Category Selection
                  EditableFieldCard(
                    label: 'CATEGORY',
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
                          selectedColor: cat.color.withValues(alpha: 0.25),
                          side: BorderSide(
                            color: isSelected ? cat.color : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? cat.color : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          onSelected: (_) => notifier.updateCategory(cat),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Action Buttons
                  ElevatedButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            final success = await notifier.saveTransaction();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Expense saved successfully!'),
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(state.isSaving ? 'Saving...' : 'Save Expense'),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: state.isSaving ? null : () => context.pop(),
                    child: const Text('Discard'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
