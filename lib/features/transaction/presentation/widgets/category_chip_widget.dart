import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../domain/entities/category_entity.dart';

class CategoryChipWidget extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChipWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.1)
        : AppColors.surface;
    final Color borderColor = isSelected
        ? AppColors.primary
        : AppColors.neutral;
    final Color textColor = isSelected
        ? AppColors.primary
        : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s12,
          horizontal: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.s8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CategoryIconMapper.fromKey(category.icon),
              size: 18,
              color: textColor,
            ),
            const SizedBox(width: AppSpacing.s8),
            Flexible(
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.roboto14w400.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
