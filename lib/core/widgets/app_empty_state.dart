import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'app_icon.dart';

class AppEmptyState extends StatelessWidget {
  final Object icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool isCompact;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double iconOuterSize = isCompact ? 80.0 : 110.0;
    final double iconMidSize = isCompact ? 64.0 : 90.0;
    final double iconInnerSize = isCompact ? 48.0 : 70.0;
    final double iconDisplaySize = isCompact ? 22.0 : 30.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s24,
          vertical: isCompact ? AppSpacing.s16 : AppSpacing.s32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing stacked circle icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: iconOuterSize,
                  height: iconOuterSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.02),
                  ),
                ),
                Container(
                  width: iconMidSize,
                  height: iconMidSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
                Container(
                  width: iconInnerSize,
                  height: iconInnerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent,
                        AppColors.primary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AppIcon(
                      icon,
                      color: AppColors.surface,
                      size: iconDisplaySize,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? AppSpacing.s12 : AppSpacing.s20),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: (isCompact ? AppTextStyles.roboto14w500 : AppTextStyles.lora18w600).copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isCompact ? AppSpacing.s6 : AppSpacing.s8),
            // Subtitle / message
            Text(
              message,
              textAlign: TextAlign.center,
              style: (isCompact ? AppTextStyles.roboto12w400 : AppTextStyles.roboto14w400).copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              SizedBox(height: isCompact ? AppSpacing.s14 : AppSpacing.s20),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 24,
                    vertical: isCompact ? 10 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: (isCompact ? AppTextStyles.roboto12w400 : AppTextStyles.roboto14w500).copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
