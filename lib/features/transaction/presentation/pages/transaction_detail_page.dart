import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/category_color_parser.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bindings/transaction_binding.dart';
import '../controllers/transaction_controller.dart';
import 'add_transaction_page.dart';
import '../../../wallet/presentation/bindings/wallet_binding.dart';

class TransactionDetailPage extends GetView<TransactionController> {
  final TransactionEntity transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == 'income';
    final Color accentColor = isIncome ? AppColors.success : AppColors.error;
    final Color categoryColor = CategoryColorParser.parse(
      transaction.category?.color,
      fallback: accentColor,
    );
    final AppIconData categoryIcon =
        CategoryIconMapper.fromKey(transaction.category?.icon);
    final String formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    ).format(transaction.amount);

    final String amountText = isIncome
        ? '+$formattedAmount'
        : '-$formattedAmount';

    final String title =
        transaction.note?.split(' - ').first ??
        (transaction.category?.name ?? 'Transaksi');
    final String noteText = transaction.note?.contains(' - ') == true
        ? transaction.note!.split(' - ').sublist(1).join(' - ')
        : '-';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const AppIcon(
            AppHugeIcons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Detail Transaksi',
          style: AppTextStyles.roboto16w600.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                  vertical: AppSpacing.s16,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.s16),
                    _buildIcon(categoryIcon, categoryColor),
                    const SizedBox(height: AppSpacing.s24),
                    Text(
                      amountText,
                      style: AppTextStyles.roboto32w600.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'IDR',
                      style: AppTextStyles.roboto14w400.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      isIncome ? 'Pemasukan' : 'Pengeluaran',
                      style: AppTextStyles.roboto14w400.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s32),
                    _buildDetailRow('Judul', title),
                    _buildDetailRow(
                      'Kategori',
                      transaction.category?.name ?? '-',
                    ),
                    _buildDetailRow('Dompet', transaction.walletName ?? '-'),
                    _buildDetailRow(
                      'Tanggal',
                      DateFormat(
                        'dd MMM yyyy',
                        'id_ID',
                      ).format(transaction.date),
                    ),
                    _buildDetailRow(
                      'Waktu',
                      () {
                        final t = transaction.time ?? '';
                        if (t.isNotEmpty) {
                          return t.length >= 5 ? t.substring(0, 5) : t;
                        }
                        return DateFormat('HH:mm', 'id_ID').format(
                          transaction.date,
                        );
                      }(),
                    ),
                    _buildDetailRow('Catatan', noteText, isLast: true),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(AppIconData icon, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppIcon(
          icon,
          color: color,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.roboto14w500.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(color: AppColors.neutral.withValues(alpha: 0.1), height: 1),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.neutral.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          _buildDeleteButton(context),
          const SizedBox(width: AppSpacing.s16),
          Expanded(child: _buildEditButton()),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDelete(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s32,
          vertical: AppSpacing.s16,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const AppIcon(AppHugeIcons.delete_outline, color: AppColors.error),
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => AddTransactionPage(transactionToEdit: transaction),
          binding: BindingsBuilder(() {
            WalletBinding().dependencies();
            TransactionBinding().dependencies();
          }),
          transition: Transition.noTransition,
          opaque: false,
        )?.then((_) {
          // After editing, pop the detail page so home data is fresh
          Get.back();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon(AppHugeIcons.edit_outlined, color: AppColors.surface, size: 20),
            const SizedBox(width: AppSpacing.s8),
            Text(
              'Edit',
              style: AppTextStyles.roboto16w600.copyWith(
                color: AppColors.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Transaksi', style: AppTextStyles.roboto16w600),
          content: Text(
            'Transaksi ini akan dihapus. Lanjutkan?',
            style: AppTextStyles.roboto14w400,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text('Batal', style: AppTextStyles.roboto14w400),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text('Hapus', style: AppTextStyles.roboto14w400),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await controller.deleteTransaction(transaction.id);
      Get.back();
    }
  }
}





