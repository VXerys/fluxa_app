import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../../../../features/transaction/presentation/pages/transaction_type_detail_page.dart';
import '../../../../features/transaction/presentation/bindings/transaction_binding.dart';
import '../../../../features/profile/presentation/controllers/profile_controller.dart';
import 'package:fluxa_app/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:fluxa_app/features/home/presentation/controllers/home_controller.dart';

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
      decimalDigits: 2,
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

    final profileController = Get.find<ProfileController>();

    return Obx(() {
      final selectedThemeIndex = profileController.selectedThemeIndex.value;
      final theme = ProfileController.cardThemes[selectedThemeIndex];
      final colors = theme['colors'] as List<Color>;
      return GestureDetector(
        onTap: () => _showEditBalanceBottomSheet(context),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.3),
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
                    style: AppTextStyles.lora14w600.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                    child: AppIcon(
                      _isObscured
                          ? AppHugeIcons.visibility_off
                          : AppHugeIcons.visibility,
                      color: AppColors.surface.withValues(alpha: 0.9),
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                balanceText,
                style: AppTextStyles.roboto32w600.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryBox(
                      label: 'Pemasukan',
                      amountText: incomeText,
                      icon: AppHugeIcons.arrow_downward,
                      onTap: () {
                        Get.to(
                          () => const TransactionTypeDetailPage(isIncome: true),
                          binding: TransactionBinding(),
                          transition: Transition.rightToLeft,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: _SummaryBox(
                      label: 'Pengeluaran',
                      amountText: expenseText,
                      icon: AppHugeIcons.arrow_upward,
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
        ),
      );
    });
  }

  Future<void> _showEditBalanceBottomSheet(BuildContext context) async {
    final walletController = Get.find<WalletController>();
    if (walletController.wallets.isEmpty) {
      final success = await walletController.createWallet(
        name: 'Cash',
        type: 'cash',
        initialBalance: 0.0,
        currency: 'IDR',
        icon: 'wallet_01',
        silent: true,
      );
      if (!success || walletController.wallets.isEmpty) {
        Get.snackbar(
          'Perhatian',
          'Gagal menyiapkan dompet utama otomatis. Silakan coba beberapa saat lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.neutral.withValues(alpha: 0.8),
          colorText: AppColors.surface,
        );
        return;
      }
    }
    final primaryWallet = walletController.wallets.first;

    Get.dialog(
      _EditBalanceDialogContent(
        primaryWallet: primaryWallet,
        walletController: walletController,
      ),
      useSafeArea: true,
    );
  }
}

class _EditBalanceDialogContent extends StatefulWidget {
  final dynamic primaryWallet;
  final WalletController walletController;

  const _EditBalanceDialogContent({
    super.key,
    required this.primaryWallet,
    required this.walletController,
  });

  @override
  State<_EditBalanceDialogContent> createState() =>
      _EditBalanceDialogContentState();
}

class _EditBalanceDialogContentState
    extends State<_EditBalanceDialogContent> {
  late final TextEditingController _balanceEditController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _balanceEditController = TextEditingController(
      text: NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 0,
      ).format(widget.primaryWallet.balance).trim(),
    );

    // Menunda pembukaan keyboard agar transisi bottom sheet berjalan smooth
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _balanceEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              Text(
                'Ubah Saldo Utama',
                style: AppTextStyles.lora24w400.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Sesuaikan jumlah saldo utama Anda saat ini secara langsung.',
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              TextField(
                controller: _balanceEditController,
                focusNode: _focusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTextStyles.roboto32w600.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: AppTextStyles.roboto32w600.copyWith(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.neutral.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.isEmpty) {
                    _balanceEditController.value = const TextEditingValue(text: '');
                    return;
                  }
                  final double amount = double.parse(digits);
                  final String formatted = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: '',
                    decimalDigits: 0,
                  ).format(amount).trim();

                  _balanceEditController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: AppColors.neutral.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.roboto14w400.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final String text = _balanceEditController.text;
                        final String cleanDigits = text.replaceAll(RegExp(r'[^0-9]'), '');
                        final double newBalance = double.tryParse(cleanDigits) ?? 0;
                        
                        Get.back();
                        
                        final success = await widget.walletController.updateWallet(
                          id: widget.primaryWallet.id,
                          balance: newBalance,
                        );
                        if (success) {
                          Get.find<HomeController>().loadSummary();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan',
                        style: AppTextStyles.roboto14w400.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
          ),
        ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String amountText;
  final AppIconData icon;
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
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.1),
          border: Border.all(
            color: AppColors.surface.withValues(alpha: 0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(icon, color: AppColors.surface, size: 20),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: AppTextStyles.roboto12w400.copyWith(
                        color: AppColors.surface.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amountText,
                style: AppTextStyles.roboto16w400.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
