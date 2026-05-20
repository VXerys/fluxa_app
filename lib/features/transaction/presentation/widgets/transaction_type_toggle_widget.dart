import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class TransactionTypeToggleWidget extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const TransactionTypeToggleWidget({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleButton(
            label: 'Pemasukan',
            type: 'income',
            selectedType: selectedType,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: _ToggleButton(
            label: 'Pengeluaran',
            type: 'expense',
            selectedType: selectedType,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final String type;
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _ToggleButton({
    required this.label,
    required this.type,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedType == type;

    return GestureDetector(
      onTap: () => onChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.s8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.neutral,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.roboto14w400.copyWith(
              color: isActive ? AppColors.surface : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
