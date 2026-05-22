import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/transaction_controller.dart';

class TransactionFilterWidget extends GetView<TransactionController> {
  final VoidCallback onOpenTypeFilter;
  final VoidCallback onOpenCategoryFilter;
  final VoidCallback onOpenDateFilter;
  final VoidCallback onOpenSortFilter;
  final VoidCallback onOpenWalletFilter;
  final VoidCallback onOpenNominalFilter;

  const TransactionFilterWidget({
    super.key,
    required this.onOpenTypeFilter,
    required this.onOpenCategoryFilter,
    required this.onOpenDateFilter,
    required this.onOpenSortFilter,
    required this.onOpenWalletFilter,
    required this.onOpenNominalFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: [
                  _buildFilterDropdown(
                    controller.filterDateRange,
                    onTap: onOpenDateFilter,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _buildFilterDropdown(
                    controller.filterType,
                    isActive: controller.filterType != 'All',
                    onTap: onOpenTypeFilter,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _buildFilterDropdown(
                    controller.filterCategory?.name ?? 'All Categories',
                    isActive: controller.filterCategory != null,
                    onTap: onOpenCategoryFilter,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: [
                  _buildFilterDropdown(
                    controller.filterSortBy,
                    onTap: onOpenSortFilter,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _buildFilterDropdown(
                    'Semua Dompet',
                    onTap: onOpenWalletFilter,
                  ), // Static UI
                  const SizedBox(width: AppSpacing.s8),
                  _buildFilterDropdown(
                    controller.filterNominal,
                    isActive:
                        controller.filterNominal != 'Rentang Nominal' &&
                        controller.filterNominal != 'Semua',
                    onTap: onOpenNominalFilter,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.s4),
            AppIcon(
              AppHugeIcons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}




