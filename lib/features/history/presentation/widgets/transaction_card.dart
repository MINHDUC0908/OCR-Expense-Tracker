import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/expense_categories.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/expense_transaction.dart';

class TransactionCard extends StatelessWidget {
  final ExpenseTransaction transaction;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidImage =
        transaction.imagePath != null &&
        File(transaction.imagePath!).existsSync();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Receipt image thumbnail or category icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: hasValidImage
                  ? Container(
                      width: 52,
                      height: 52,
                      color: Colors.black,
                      child: Image.file(
                        File(transaction.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: transaction.category.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: transaction.category.color.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          transaction.category.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
            ),

            const SizedBox(width: 14),

            // Merchant & Date & Category Chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchantName,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormatter.display(transaction.date),
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: transaction.category.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.category.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: transaction.category.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount & Delete button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatVnd(transaction.amount),
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
