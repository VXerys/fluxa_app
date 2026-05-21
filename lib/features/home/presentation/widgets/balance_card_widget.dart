import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../../../../features/transaction/presentation/pages/transaction_type_detail_page.dart';
import '../../../../features/transaction/presentation/bindings/transaction_binding.dart';

class BalanceCardWidget extends StatefulWidget {
  final HomeSummaryEntity? summary;

  const BalanceCardWidget({super.key, required this.summary});

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  bool _isObscured = false;

  String _formatAmount(double value) {
    if (_isObscured) return 'Rp •••••••';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final String balanceText = widget.summary == null
        ? '—'
        : _formatAmount(widget.summary!.balance);
    final String incomeText = widget.summary == null
        ? '—'
        : _formatAmount(widget.summary!.totalIncome);
    final String expenseText = widget.summary == null
        ? '—'
        : _formatAmount(widget.summary!.totalExpense);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.cardGradient1Start, AppColors.cardGradient1End],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradient1Start.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Saldo (IDR)',
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.surface.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
                child: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.surface.withOpacity(0.9),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            balanceText,
            style: AppTextStyles.lora36w400.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  label: 'Pemasukan',
                  amountText: incomeText,
                  icon: Icons.arrow_downward,
                  onTap: () {
                    Get.to(
                      () => const TransactionTypeDetailPage(isIncome: true),
                      binding: TransactionBinding(),
                      transition: Transition.rightToLeft,
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: _SummaryBox(
                  label: 'Pengeluaran',
                  amountText: expenseText,
                  icon: Icons.arrow_upward,
                  onTap: () {
                    Get.to(
                      () => const TransactionTypeDetailPage(isIncome: false),
                      binding: TransactionBinding(),
                      transition: Transition.rightToLeft,
                    );
                  },
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
  final VoidCallback? onTap;

  const _SummaryBox({
    required this.label,
    required this.amountText,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.1),
          border: Border.all(color: AppColors.surface.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.surface, size: 14),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: AppTextStyles.roboto12w400.copyWith(
                        color: AppColors.surface.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amountText,
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
