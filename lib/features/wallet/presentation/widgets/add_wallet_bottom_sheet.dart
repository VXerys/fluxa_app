import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/wallet_controller.dart';

class AddWalletBottomSheet extends StatefulWidget {
  const AddWalletBottomSheet({super.key});

  @override
  State<AddWalletBottomSheet> createState() => _AddWalletBottomSheetState();
}

class _AddWalletBottomSheetState extends State<AddWalletBottomSheet> {
  final WalletController _controller = Get.find<WalletController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String? _selectedType;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Nama dompet tidak boleh kosong');
      return;
    }
    if (_selectedType == null || _selectedType!.isEmpty) {
      Get.snackbar('Error', 'Tipe dompet wajib dipilih');
      return;
    }

    final String normalized = _balanceController.text
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    final double initialBalance = double.tryParse(normalized) ?? 0;

    final bool success = await _controller.createWallet(
      name: name,
      type: _selectedType!,
      initialBalance: initialBalance,
      currency: 'IDR',
      icon: null,
      color: null,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s16,
        right: AppSpacing.s16,
        top: AppSpacing.s16,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppSpacing.s48,
              height: AppSpacing.s4,
              decoration: BoxDecoration(
                color: AppColors.neutral.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppSpacing.s12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Tambah Dompet Baru',
            style: AppTextStyles.roboto18w600,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Dompet',
              labelStyle: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.s12),
                borderSide: const BorderSide(color: AppColors.primaryLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.s12),
                borderSide: const BorderSide(color: AppColors.primaryLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.s12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Tipe Dompet',
            style: AppTextStyles.roboto14w500,
          ),
          const SizedBox(height: AppSpacing.s8),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              _buildTypeChip(label: 'Tunai', value: 'cash'),
              _buildTypeChip(label: 'Bank', value: 'bank'),
              _buildTypeChip(label: 'E-Wallet', value: 'ewallet'),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          TextField(
            controller: _balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Saldo Awal',
              prefixText: 'Rp ',
              labelStyle: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.s12),
                borderSide: const BorderSide(color: AppColors.primaryLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.s12),
                borderSide: const BorderSide(color: AppColors.primaryLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.s12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Mata Uang',
            style: AppTextStyles.roboto14w500,
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            'IDR',
            style: AppTextStyles.roboto16w400,
          ),
          const SizedBox(height: AppSpacing.s24),
          Obx(() {
            return SizedBox(
              height: AppSpacing.s48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.s12),
                  ),
                ),
                onPressed: _controller.isSubmitting ? null : _submit,
                child: _controller.isSubmitting
                    ? const SizedBox(
                        width: AppSpacing.s20,
                        height: AppSpacing.s20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.surface,
                          ),
                        ),
                      )
                    : Text(
                        'Simpan Dompet',
                        style: AppTextStyles.roboto16w600.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required String value,
  }) {
    final bool selected = _selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: AppTextStyles.roboto14w400.copyWith(
        color: selected ? AppColors.surface : AppColors.textPrimary,
      ),
      onSelected: (isSelected) {
        setState(() {
          _selectedType = isSelected ? value : null;
        });
      },
    );
  }
}
