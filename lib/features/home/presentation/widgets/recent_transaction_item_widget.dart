import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';

class RecentTransactionItemWidget extends StatelessWidget {
  final TransactionEntity transaction;

  const RecentTransactionItemWidget({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == 'income';
    final Color accentColor =
        isIncome ? AppColors.success : AppColors.error;
    final String icon = transaction.category?.icon ?? (isIncome ? '💰' : '💸');

    final String? note = transaction.note?.trim();
    final bool hasNote = note != null && note.isNotEmpty;
    final String title =
        hasNote ? note : (transaction.category?.name ?? 'Transaksi');
    final String? subtitle = hasNote ? transaction.category?.name : null;
    final String dateText = DateFormat('dd MMM yyyy').format(transaction.date);

    final String formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(transaction.amount);
    final String amountText =
        isIncome ? '+$formattedAmount' : '-$formattedAmount';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        children: [
          Container(
            width: AppSpacing.s32,
            height: AppSpacing.s32,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: AppTextStyles.roboto16w400.copyWith(
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.roboto14w400.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.roboto12w400.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s4),
                Text(
                  dateText,
                  style: AppTextStyles.roboto12w400.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Text(
            amountText,
            style: AppTextStyles.roboto14w400.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
