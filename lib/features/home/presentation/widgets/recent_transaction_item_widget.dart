import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/category_color_parser.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';

class RecentTransactionItemWidget extends StatelessWidget {
  final TransactionEntity transaction;

  const RecentTransactionItemWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == 'income';
    final Color accentColor = isIncome ? AppColors.success : AppColors.error;
    final Color categoryColor = CategoryColorParser.parse(
      transaction.category?.color,
      fallback: accentColor,
    );
    final IconData categoryIcon =
        CategoryIconMapper.fromKey(transaction.category?.icon);

    final String? note = transaction.note?.trim();
    final bool hasNote = note != null && note.isNotEmpty;
    final String title = hasNote
        ? note
        : (transaction.category?.name ?? 'Transaksi');
    final String? subtitle = hasNote ? transaction.category?.name : null;
    final String formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(transaction.amount);
    final String amountText = isIncome
        ? '+$formattedAmount'
        : '-$formattedAmount';
    final String timeText =
        (transaction.time != null && transaction.time!.isNotEmpty)
            ? transaction.time!
            : DateFormat('HH:mm').format(transaction.date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                categoryIcon,
                size: 24,
                color: categoryColor,
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
                  style: AppTextStyles.roboto16w400.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subtitle ?? 'Cash',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.roboto12w400.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeText,
                style: AppTextStyles.roboto12w400.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amountText,
                style: AppTextStyles.roboto14w400.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
