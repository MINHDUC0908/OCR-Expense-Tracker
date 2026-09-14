// lib/features/history/presentation/widgets/filter_bar.dart
// Horizontal filter chips for category selection + search field.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/expense_categories.dart';

class FilterBar extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory?> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;

  const FilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search merchant or amount...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // "All" filter chip
              ChoiceChip(
                label: const Text('All'),
                selected: selectedCategory == null,
                selectedColor: AppColors.primaryContainer,
                side: BorderSide(
                  color: selectedCategory == null ? AppColors.primary : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: selectedCategory == null ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: selectedCategory == null ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
                onSelected: (selected) {
                  if (selected) onCategoryChanged(null);
                },
              ),
              const SizedBox(width: 8),

              // Category chips
              ...ExpenseCategory.values.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Text(cat.emoji, style: const TextStyle(fontSize: 12)),
                    label: Text(cat.displayName),
                    selected: isSelected,
                    selectedColor: cat.color.withValues(alpha: 0.25),
                    side: BorderSide(
                      color: isSelected ? cat.color : AppColors.border,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? cat.color : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      onCategoryChanged(selected ? cat : null);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
