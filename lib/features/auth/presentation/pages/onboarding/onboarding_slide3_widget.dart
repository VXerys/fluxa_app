import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_styles.dart';

class OnboardingSlide3Widget extends StatelessWidget {
  const OnboardingSlide3Widget({
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
                    child: Center(
                      child: SizedBox(
                        width: 200,
                        height: 180,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 24,
                              top: 72,
                              child: Transform.rotate(
                                angle: -0.35,
                                child: const Icon(
                                  Icons.credit_card,
                                  color: Colors.green,
                                  size: 56,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 56,
                              top: 44,
                              child: Transform.rotate(
                                angle: -0.12,
                                child: const Icon(
                                  Icons.credit_card,
                                  color: Colors.amber,
                                  size: 56,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 88,
                              top: 38,
                              child: Transform.rotate(
                                angle: 0.12,
                                child: const Icon(
                                  Icons.credit_card,
                                  color: Colors.purple,
                                  size: 56,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 118,
                              top: 52,
                              child: Transform.rotate(
                                angle: 0.32,
                                child: const Icon(
                                  Icons.credit_card,
                                  color: Colors.blue,
                                  size: 56,
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
                        'MANAGEMENT',
                        style: AppTextStyles.roboto12w400.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Total Control',
                        style: AppTextStyles.roboto32w600.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Manage all your wallets and budgets manually in one place. '
                        'Your data stays 100% private - no bank connections, just simple tracking.',
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
                          const Spacer(),
                          GestureDetector(
                            onTap: onNext,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s32,
                                vertical: AppSpacing.s16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E),
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
