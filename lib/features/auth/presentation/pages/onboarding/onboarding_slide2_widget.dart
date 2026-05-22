import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_styles.dart';

class OnboardingSlide2Widget extends StatelessWidget {
  const OnboardingSlide2Widget({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Column(
            children: [
              Expanded(
                flex: 55,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.s24),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pie_chart, size: 80, color: Colors.blue),
                          SizedBox(width: AppSpacing.s16),
                          Icon(Icons.bar_chart, size: 60, color: Colors.amber),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 45,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STATISTICS',
                        style: AppTextStyles.roboto12w400.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Gain Deep\nInsights',
                        style: AppTextStyles.roboto32w600.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Analyze your income and expense trends with detailed reports '
                        'to make smarter financial decisions.',
                        style: AppTextStyles.roboto14w400.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _buildDot(),
                          const SizedBox(width: AppSpacing.s12),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          _buildDot(),
                          const SizedBox(width: AppSpacing.s12),
                          _buildDot(),
                          const Spacer(),
                          GestureDetector(
                            onTap: onNext,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s32,
                                vertical: AppSpacing.s16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x2D000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Next \u2192',
                                style: AppTextStyles.roboto18w600.copyWith(
                                  color: AppColors.surface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Color(0xFFDDE1E8),
        shape: BoxShape.circle,
      ),
    );
  }
}
