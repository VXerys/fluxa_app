import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_styles.dart';

class OnboardingSlide4Widget extends StatelessWidget {
  const OnboardingSlide4Widget({
    super.key,
    required this.onGetStarted,
  });

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3E5F5),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.s24),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5).withValues(alpha: 0.38),
                        borderRadius: BorderRadius.circular(AppSpacing.s24),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                size: 90,
                                color: Colors.purple,
                              ),
                              ..._buildCoins(),
                            ],
                          ),
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
                        'SAVINGS',
                        style: AppTextStyles.roboto12w400.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Grow Your\nWealth',
                        style: AppTextStyles.roboto32w600.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Start saving more effectively by tracking where your money goes '
                        'and cutting unnecessary expenses.',
                        style: AppTextStyles.roboto14w400.copyWith(
                          color: const Color(0xFF6B7280),
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
                          _buildDot(),
                          const SizedBox(width: AppSpacing.s12),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onGetStarted,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s32,
                                vertical: AppSpacing.s16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple,
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
                                'Get Started \u2192',
                                style: AppTextStyles.roboto18w600.copyWith(
                                  color: Colors.white,
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

  List<Widget> _buildCoins() {
    const List<double> angles = [-2.3, -1.6, -0.9, -0.25, 0.55, 1.3];
    const double radius = 84;

    return List<Widget>.generate(angles.length, (int index) {
      final double angle = angles[index];
      final double dx = math.cos(angle) * radius;
      final double dy = math.sin(angle) * radius;

      return Positioned(
        left: 110 + dx - 14,
        top: 110 + dy - 14,
        child: const Icon(
          Icons.monetization_on,
          size: 28,
          color: Colors.amber,
        ),
      );
    });
  }

  Widget _buildDot() {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
    );
  }
}
