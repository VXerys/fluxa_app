import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_rounded,
              size: 64,
              color: AppColors.neutral,
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Segera Hadir 📊',
              style: AppTextStyles.lora24w400.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Fitur statistik sedang dalam pengembangan',
              style: AppTextStyles.roboto16w400.copyWith(
                color: AppColors.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
