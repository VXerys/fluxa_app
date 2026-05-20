import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class TransactionFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const TransactionFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterChip(
              label: 'Semua',
              isActive: selectedFilter == 'Semua',
              onTap: () => onFilterChanged('Semua'),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: _FilterChip(
              label: 'Pemasukan',
              isActive: selectedFilter == 'Pemasukan',
              onTap: () => onFilterChanged('Pemasukan'),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: _FilterChip(
              label: 'Pengeluaran',
              isActive: selectedFilter == 'Pengeluaran',
              onTap: () => onFilterChanged('Pengeluaran'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isActive ? AppColors.primary : AppColors.surface;
    final Color borderColor =
        isActive ? AppColors.primary : AppColors.neutral;
    final Color textColor =
        isActive ? AppColors.surface : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.s8),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.roboto14w400.copyWith(
              color: textColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
