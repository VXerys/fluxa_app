import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/voice_transaction_draft_params.dart';
import '../../domain/entities/voice_transaction_entity.dart';

class VoiceTransactionDraftCardWidget extends StatelessWidget {
  final VoiceTransactionEntity transaction;
  final VoiceTransactionDraftParams? draft;

  const VoiceTransactionDraftCardWidget({
    super.key,
    required this.transaction,
    this.draft,
  });

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final String titleLabel =
        draft?.displayTitle ??
        _normalizedOrNull(transaction.title) ??
        'Transaksi suara';
    final double amountValue = draft?.amount ?? transaction.amount;
    String transactionCategoryLabel = '';
    if (transaction.category.isNotEmpty) {
      transactionCategoryLabel = transaction.category;
      if (transaction.subcategory != null && transaction.subcategory!.trim().isNotEmpty) {
        transactionCategoryLabel += ' • ${transaction.subcategory}';
      }
    }
    final String categoryLabel =
        draft?.displayCategory ??
        (transactionCategoryLabel.isEmpty ? 'Belum terdeteksi' : transactionCategoryLabel);
    final String? walletLabel = draft?.displayWallet ?? _normalizedOrNull(transaction.wallet);
    final String descriptionLabel =
        draft?.displayDescription ??
        _normalizedOrNull(transaction.description) ??
        '-';
    final String currencyLabel = draft?.effectiveCurrency ?? transaction.currency;
    final String typeLabel = _formatType(draft?.type ?? transaction.type);

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
          Text(
            'Draft transaksi',
            style: AppTextStyles.roboto16w600.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            titleLabel,
            style: AppTextStyles.roboto18w600.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            _currencyFormatter.format(amountValue),
            style: AppTextStyles.roboto32w600.copyWith(
              color: AppColors.textPrimary,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: AppSpacing.s14),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            alignment: WrapAlignment.start,
            children: [
              _ValueChip(
                label: typeLabel,
                color: (draft?.type ?? transaction.type) == 'income'
                    ? AppColors.success
                    : AppColors.error,
              ),
              _ValueChip(
                label: categoryLabel,
                color: AppColors.primary,
              ),
              _WalletChip(wallet: walletLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.s18),
          _DraftRow(
            label: 'Judul',
            valueText: titleLabel,
          ),
          _DraftRow(
            label: 'Jenis',
            valueText: typeLabel,
          ),
          _DraftRow(
            label: 'Nominal',
            valueText: _currencyFormatter.format(amountValue),
          ),
          _DraftRow(
            label: 'Kategori',
            valueText: categoryLabel,
          ),
          _DraftRow(
            label: 'Dompet',
            valueWidget: _WalletValue(wallet: walletLabel),
          ),
          _DraftRow(
            label: 'Deskripsi',
            valueText: descriptionLabel,
          ),
          _DraftRow(label: 'Mata uang', valueText: currencyLabel),
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

class _WalletChip extends StatelessWidget {
  final String? wallet;

  const _WalletChip({required this.wallet});

  @override
  Widget build(BuildContext context) {
    final String? detectedWallet = wallet;
    return _ValueChip(
      label: detectedWallet != null && detectedWallet.isNotEmpty
          ? detectedWallet
          : 'Belum terdeteksi',
      color: detectedWallet != null && detectedWallet.isNotEmpty
          ? AppColors.accent
          : AppColors.warning,
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
        const _WalletChip(wallet: null),
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

String? _normalizedOrNull(String? value) {
  if (value == null) return null;
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
