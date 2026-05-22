import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_styles.dart';

class OnboardingSlide1Widget extends StatelessWidget {
  const OnboardingSlide1Widget({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

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
                    child: Center(
                      child: SizedBox(
                        width: 240,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.mic,
                              size: 80,
                              color: AppColors.primary,
                            ),
                            Positioned(
                              left: 12,
                              top: 92,
                              child: Transform.rotate(
                                angle: -0.45,
                                child: const Icon(
                                  Icons.wifi_rounded,
                                  size: 34,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 28,
                              top: 68,
                              child: Transform.rotate(
                                angle: -0.2,
                                child: const Icon(
                                  Icons.wifi_rounded,
                                  size: 24,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 76,
                              child: Transform.rotate(
                                angle: 0.18,
                                child: const Icon(
                                  Icons.wifi_rounded,
                                  size: 32,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                        'QUICK RECORD',
                        style: AppTextStyles.roboto12w400.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Record in\nSeconds',
                        style: AppTextStyles.roboto32w600.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Say "Coffee 25k using Cash" or scan a receipt. '
                        'Our smart voice and scan features make tracking effortless and lightning fast!',
                        style: AppTextStyles.roboto14w400.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: onSkip,
                          child: Text(
                            'Skip',
                            style: AppTextStyles.roboto18w500.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          _buildDot(),
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
                                color: AppColors.primary,
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
