import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/category_color_parser.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionItemWidget extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionItemWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == 'income';
    final Color accentColor = isIncome ? AppColors.success : AppColors.error;

    final String? note = transaction.note?.trim();
    final bool hasNote = note != null && note.isNotEmpty;
    final String title = hasNote
        ? note
        : (transaction.category?.name ?? 'Transaksi');
    final String subtitleText = transaction.category?.name ?? 'Umum';
    final String subtitle = '$subtitleText • Tunai';
    final Color categoryColor = CategoryColorParser.parse(
      transaction.category?.color,
      fallback: accentColor,
    );
    final IconData categoryIcon =
        CategoryIconMapper.fromKey(transaction.category?.icon);
    final String dateText = DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(transaction.date);
    final String timeText =
        transaction.time ??
        DateFormat('HH:mm', 'id_ID').format(transaction.date);
    final String dateTimeText = '$timeText $dateText';

    final String formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(transaction.amount);

    // Format to "k" for thousands if it ends with 000
    String shortAmount = formattedAmount;
    if (shortAmount.endsWith('.000')) {
      shortAmount = '${shortAmount.substring(0, shortAmount.length - 4)}k';
    }

    final String amountText = isIncome ? '+$shortAmount' : '-$shortAmount';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent, // Transparan agar tidak konflik dengan dekorasi parent
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                categoryIcon,
                color: categoryColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.roboto16w600.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.roboto14w400.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                amountText,
                style: AppTextStyles.roboto16w600.copyWith(color: accentColor),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                dateTimeText,
                style: AppTextStyles.roboto12w400.copyWith(
                  color: AppColors.neutral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
