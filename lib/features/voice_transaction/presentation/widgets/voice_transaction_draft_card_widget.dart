import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/icons/app_huge_icons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/voice_transaction_entity.dart';

class VoiceTransactionDraftCardWidget extends StatelessWidget {
  final VoiceTransactionEntity transaction;
  final VoidCallback onSave;
  final VoidCallback onEdit;

  const VoiceTransactionDraftCardWidget({
    super.key,
    required this.transaction,
    required this.onSave,
    required this.onEdit,
  });

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(
                AppHugeIcons.receipt,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  'Draft transaksi',
                  style: AppTextStyles.roboto18w600.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          _DraftRow(
            label: 'Jenis',
            valueWidget: _ValueChip(
              label: _formatType(transaction.type),
              color: transaction.type == 'income'
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
          _DraftRow(
            label: 'Nominal',
            valueText: _currencyFormatter.format(transaction.amount),
          ),
          _DraftRow(
            label: 'Kategori',
            valueWidget: _ValueChip(
              label: transaction.category.isEmpty
                  ? 'Belum terdeteksi'
                  : transaction.category,
              color: AppColors.primary,
            ),
          ),
          _DraftRow(
            label: 'Dompet',
            valueWidget: _WalletValue(wallet: transaction.wallet),
          ),
          _DraftRow(
            label: 'Deskripsi',
            valueText: transaction.description ?? '-',
          ),
          _DraftRow(label: 'Mata uang', valueText: transaction.currency),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onEdit,
              child: const Text('Edit draft'),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Simpan draft'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftRow extends StatelessWidget {
  final String label;
  final String? valueText;
  final Widget? valueWidget;

  const _DraftRow({
    required this.label,
    this.valueText,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: AppTextStyles.roboto13w500.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  valueWidget ??
                  Text(
                    (valueText ?? '').isEmpty ? '-' : valueText!,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.roboto14w600.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ValueChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: AppTextStyles.roboto12w600.copyWith(color: color),
      ),
    );
  }
}

class _WalletValue extends StatelessWidget {
  final String? wallet;

  const _WalletValue({required this.wallet});

  @override
  Widget build(BuildContext context) {
    final String? detectedWallet = wallet;
    if (detectedWallet != null && detectedWallet.isNotEmpty) {
      return _ValueChip(label: detectedWallet, color: AppColors.accent);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const _ValueChip(label: 'Belum terdeteksi', color: AppColors.warning),
        const SizedBox(height: AppSpacing.s6),
        Text(
          'Nanti bisa dipilih manual sebelum transaksi disimpan.',
          textAlign: TextAlign.right,
          style: AppTextStyles.roboto12w400.copyWith(
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

String _formatType(String type) {
  switch (type) {
    case 'income':
      return 'Pemasukan';
    case 'expense':
      return 'Pengeluaran';
    default:
      return type.isEmpty ? 'Belum terdeteksi' : type;
  }
}
