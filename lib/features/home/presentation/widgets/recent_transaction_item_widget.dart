import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/category_color_parser.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/presentation/controllers/transaction_controller.dart';
import '../../../transaction/presentation/pages/add_transaction_page.dart';
import '../../../transaction/presentation/pages/transaction_detail_page.dart';
import '../controllers/home_controller.dart';

class RecentTransactionItemWidget extends StatelessWidget {
  final TransactionEntity transaction;

  const RecentTransactionItemWidget({super.key, required this.transaction});

  /// Formats time string: trims `HH:mm:ss` → `HH:mm`.
  /// Falls back to formatting transaction.date if time is null/empty.
  String _formatTime() {
    final t = transaction.time;
    if (t != null && t.isNotEmpty) {
      // If stored as HH:mm:ss or HH:mm, take only first 5 chars (HH:mm)
      return t.length >= 5 ? t.substring(0, 5) : t;
    }
    return DateFormat('HH:mm').format(transaction.date);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Transaksi', style: AppTextStyles.roboto16w600),
        content: Text(
          'Transaksi ini akan dihapus. Lanjutkan?',
          style: AppTextStyles.roboto14w400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text('Batal', style: AppTextStyles.roboto14w400),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Hapus', style: AppTextStyles.roboto14w400),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final txController = Get.find<TransactionController>();
      await txController.deleteTransaction(transaction.id);
      // Refresh home summary
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().loadSummary();
      }
    }
  }

  void _openEdit() {
    Get.to(
      () => AddTransactionPage(transactionToEdit: transaction),
      transition: Transition.noTransition,
      opaque: false,
    )?.then((_) {
      // Refresh home summary after returning from edit
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadSummary();
      }
    });
  }

  void _openDetail() {
    Get.to(
      () => TransactionDetailPage(transaction: transaction),
      transition: Transition.rightToLeft,
    )?.then((_) {
      // Refresh home summary in case detail triggered a delete
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadSummary();
      }
    });
  }

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
    final String walletLabel =
        transaction.walletName?.trim().isNotEmpty == true
        ? transaction.walletName!
        : 'Dompet';
    final String formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    ).format(transaction.amount);
    final String amountText = isIncome
        ? '+$formattedAmount'
        : '-$formattedAmount';
    final String timeText = _formatTime();

    final Widget cardContent = GestureDetector(
      onTap: _openDetail,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        color: AppColors.surface, // Solid white background
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.16),
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
                          walletLabel,
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
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Slidable(
          key: ValueKey(transaction.id),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              CustomSlidableAction(
                onPressed: (context) => _confirmDelete(context),
                backgroundColor: AppColors.error.withValues(alpha: 0.12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              CustomSlidableAction(
                onPressed: (context) => _openEdit(),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_outlined, color: AppColors.primary, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child: cardContent,
        ),
      ),
    );
  }
}
