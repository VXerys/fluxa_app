import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/home_summary_entity.dart';

class BalanceCardWidget extends StatelessWidget {
  final HomeSummaryEntity? summary;

  const BalanceCardWidget({
    super.key,
    required this.summary,
  });

  String _formatAmount(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final String balanceText = summary == null
        ? '—'
        : _formatAmount(summary!.balance);
    final String incomeText = summary == null
        ? '—'
        : _formatAmount(summary!.totalIncome);
    final String expenseText = summary == null
        ? '—'
        : _formatAmount(summary!.totalExpense);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.s24 - AppSpacing.s4),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF1565C0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo (IDR)',
            style: AppTextStyles.roboto12w400.copyWith(
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            balanceText,
            style: AppTextStyles.lora36w400.copyWith(
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  label: 'Pemasukan',
                  amountText: incomeText,
                  icon: Icons.arrow_downward,
                  accentColor: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: _SummaryBox(
                  label: 'Pengeluaran',
                  amountText: expenseText,
                  icon: Icons.arrow_upward,
                  accentColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String amountText;
  final IconData icon;
  final Color accentColor;

  const _SummaryBox({
    required this.label,
    required this.amountText,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.s12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: AppSpacing.s16),
              const SizedBox(width: AppSpacing.s8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.roboto12w400.copyWith(
                    color: AppColors.surface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            amountText,
            style: AppTextStyles.roboto14w400.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
