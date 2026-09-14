// lib/features/review/presentation/widgets/editable_field_card.dart
// Form field wrapper with clear title, prefix icon, and modern input decoration.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class EditableFieldCard extends StatelessWidget {
  final String label;
  final Widget child;
  final IconData? icon;
  final String? helperText;

  const EditableFieldCard({
    super.key,
    required this.label,
    required this.child,
    this.icon,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ],
    );
  }
}
