import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/wallet_controller.dart';

class _WalletTypeOption {
  final String label;
  final String value;
  final AppIconData icon;

  const _WalletTypeOption({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _WalletIconOption {
  final String key;
  final AppIconData icon;

  const _WalletIconOption({required this.key, required this.icon});
}

class AddWalletBottomSheet extends StatefulWidget {
  const AddWalletBottomSheet({super.key});

  @override
  State<AddWalletBottomSheet> createState() => _AddWalletBottomSheetState();
}

class _AddWalletBottomSheetState extends State<AddWalletBottomSheet> {
  static final NumberFormat _rupiahInputFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 2,
  );

  static const List<_WalletTypeOption> _typeOptions = <_WalletTypeOption>[
    // Commented out non-cash types for now
    // _WalletTypeOption(
    //   label: 'Bank',
    //   value: 'bank',
    //   icon: AppHugeIcons.account_balance_outlined,
    // ),
    // _WalletTypeOption(
    //   label: 'E-Wallet',
    //   value: 'ewallet',
    //   icon: AppHugeIcons.account_balance_wallet_outlined,
    // ),
    _WalletTypeOption(
      label: 'Kas',
      value: 'cash',
      icon: AppHugeIcons.payments_outlined,
    ),
  ];

  static const List<_WalletIconOption> _iconOptions = <_WalletIconOption>[
    _WalletIconOption(
      key: 'wallet_01',
      icon: AppHugeIcons.account_balance_wallet_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_02',
      icon: AppHugeIcons.account_balance_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_03',
      icon: AppHugeIcons.credit_card_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_04',
      icon: AppHugeIcons.request_quote_outlined,
    ),
    _WalletIconOption(key: 'wallet_05', icon: AppHugeIcons.savings_outlined),
    _WalletIconOption(
      key: 'wallet_06',
      icon: AppHugeIcons.attach_money_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_07',
      icon: AppHugeIcons.account_balance_wallet_outlined,
    ),
    _WalletIconOption(key: 'wallet_08', icon: AppHugeIcons.sync_alt_outlined),
    _WalletIconOption(key: 'wallet_09', icon: AppHugeIcons.badge_outlined),
    _WalletIconOption(key: 'wallet_10', icon: AppHugeIcons.swap_horiz_outlined),
    _WalletIconOption(
      key: 'wallet_11',
      icon: AppHugeIcons.trending_up_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_12',
      icon: AppHugeIcons.receipt_long_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_13',
      icon: AppHugeIcons.currency_bitcoin_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_14',
      icon: AppHugeIcons.description_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_15',
      icon: AppHugeIcons.shopping_bag_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_16',
      icon: AppHugeIcons.shopping_cart_outlined,
    ),
    _WalletIconOption(key: 'wallet_17', icon: AppHugeIcons.storefront_outlined),
    _WalletIconOption(key: 'wallet_18', icon: AppHugeIcons.store_outlined),
    _WalletIconOption(
      key: 'wallet_19',
      icon: AppHugeIcons.card_giftcard_outlined,
    ),
    _WalletIconOption(key: 'wallet_20', icon: AppHugeIcons.redeem_outlined),
    _WalletIconOption(
      key: 'wallet_21',
      icon: AppHugeIcons.bookmark_border_outlined,
    ),
    _WalletIconOption(key: 'wallet_22', icon: AppHugeIcons.checkroom_outlined),
    _WalletIconOption(key: 'wallet_23', icon: AppHugeIcons.local_mall_outlined),
    _WalletIconOption(
      key: 'wallet_24',
      icon: AppHugeIcons.directions_car_outlined,
    ),
    _WalletIconOption(key: 'wallet_25', icon: AppHugeIcons.train_outlined),
    _WalletIconOption(key: 'wallet_26', icon: AppHugeIcons.flight_outlined),
    _WalletIconOption(
      key: 'wallet_27',
      icon: AppHugeIcons.directions_railway_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_28',
      icon: AppHugeIcons.directions_bus_outlined,
    ),
    _WalletIconOption(key: 'wallet_29', icon: AppHugeIcons.pedal_bike_outlined),
    _WalletIconOption(key: 'wallet_30', icon: AppHugeIcons.waves_outlined),
    _WalletIconOption(
      key: 'wallet_31',
      icon: AppHugeIcons.medical_services_outlined,
    ),
    _WalletIconOption(key: 'wallet_32', icon: AppHugeIcons.local_hospital),
    _WalletIconOption(key: 'wallet_33', icon: AppHugeIcons.wifi_outlined),
    _WalletIconOption(key: 'wallet_34', icon: AppHugeIcons.flash_on_outlined),
    _WalletIconOption(key: 'wallet_35', icon: AppHugeIcons.restaurant_outlined),
    _WalletIconOption(key: 'wallet_36', icon: AppHugeIcons.local_cafe_outlined),
    _WalletIconOption(key: 'wallet_37', icon: AppHugeIcons.cake_outlined),
    _WalletIconOption(key: 'wallet_38', icon: AppHugeIcons.icecream_outlined),
    _WalletIconOption(key: 'wallet_39', icon: AppHugeIcons.fastfood_outlined),
    _WalletIconOption(
      key: 'wallet_40',
      icon: AppHugeIcons.sports_esports_outlined,
    ),
    _WalletIconOption(key: 'wallet_41', icon: AppHugeIcons.music_note_outlined),
    _WalletIconOption(
      key: 'wallet_42',
      icon: AppHugeIcons.photo_camera_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_43',
      icon: AppHugeIcons.sports_basketball_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_44',
      icon: AppHugeIcons.sports_tennis_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_45',
      icon: AppHugeIcons.sports_golf_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_46',
      icon: AppHugeIcons.sports_soccer_outlined,
    ),
    _WalletIconOption(
      key: 'wallet_47',
      icon: AppHugeIcons.beach_access_outlined,
    ),
    _WalletIconOption(key: 'wallet_48', icon: AppHugeIcons.self_improvement),
  ];

  final WalletController _controller = Get.find<WalletController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  String _selectedType = 'cash';
  int _selectedIconIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _onBalanceChanged(String value) {
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      if (_balanceController.text.isNotEmpty) {
        _balanceController.value = const TextEditingValue(text: '');
      }
      return;
    }

    final double amount = double.parse(digits) / 100;
    final String formatted = _rupiahInputFormatter.format(amount).trim();

    if (_balanceController.text == formatted) {
      return;
    }

    _balanceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _submit() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Nama dompet tidak boleh kosong');
      return;
    }
    if (_selectedType.isEmpty) {
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
      type: _selectedType,
      initialBalance: initialBalance,
      currency: 'IDR',
      icon: _iconOptions[_selectedIconIndex].key,
      color: null,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.94,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back<void>(),
                    icon: const AppIcon(
                      AppHugeIcons.arrow_back,
                      color: AppColors.textPrimary,
                      size: 30,
                    ),
                    splashRadius: 22,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      'Tambah Dompet Baru',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.lora18w600.copyWith(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Obx(() {
                    return InkWell(
                      onTap: _controller.isSubmitting ? null : _submit,
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        child: _controller.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            : const AppIcon(
                                AppHugeIcons.check,
                                color: AppColors.textPrimary,
                                size: 32,
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s6,
                  AppSpacing.s16,
                  AppSpacing.s16 + keyboardBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Dompet',
                      style: AppTextStyles.lora18w600.copyWith(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _buildFieldLabel('Nama Dompet'),
                    const SizedBox(height: AppSpacing.s8),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        hintText: 'misal: BCA, GoPay, Tunai',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _buildFieldLabel('Mata Uang Dompet'),
                    const SizedBox(height: AppSpacing.s8),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.s16),
                        border: Border.all(
                          color: AppColors.neutral.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const AppIcon(
                              AppHugeIcons.public_outlined,
                              size: 24,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IDR',
                                  style: AppTextStyles.roboto18w600.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Indonesian Rupiah',
                                  style: AppTextStyles.roboto14w400.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _buildFieldLabel('Saldo Awal (Opsional)'),
                    const SizedBox(height: AppSpacing.s8),
                    TextField(
                      controller: _balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: _onBalanceChanged,
                      textInputAction: TextInputAction.done,
                      decoration: _inputDecoration(
                        hintText: '0,00',
                        prefixText: 'Rp ',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    _buildFieldLabel('Tipe'),
                    const SizedBox(height: AppSpacing.s10),
                    Wrap(
                      spacing: AppSpacing.s10,
                      runSpacing: AppSpacing.s10,
                      children: List<Widget>.generate(_typeOptions.length, (
                        int index,
                      ) {
                        final _WalletTypeOption option = _typeOptions[index];
                        final bool isSelected = _selectedType == option.value;
                        return _buildTypeChip(option, isSelected);
                      }),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    _buildFieldLabel('Ikon Umum'),
                    const SizedBox(height: AppSpacing.s10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.neutral.withValues(alpha: 0.14),
                        ),
                      ),
                      child: GridView.builder(
                        itemCount: _iconOptions.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              mainAxisSpacing: AppSpacing.s10,
                              crossAxisSpacing: AppSpacing.s10,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          final _WalletIconOption item = _iconOptions[index];
                          final bool selected = index == _selectedIconIndex;
                          return _buildIconItem(
                            item: item,
                            selected: selected,
                            onTap: () {
                              setState(() {
                                _selectedIconIndex = index;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.lora16w600.copyWith(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      hintStyle: AppTextStyles.roboto16w400.copyWith(
        color: AppColors.textSecondary.withValues(alpha: 0.72),
        fontSize: 13,
      ),
      prefixStyle: AppTextStyles.roboto16w400.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.s16),
        borderSide: BorderSide(
          color: AppColors.neutral.withValues(alpha: 0.12),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.s16),
        borderSide: BorderSide(
          color: AppColors.neutral.withValues(alpha: 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.s16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }

  Widget _buildTypeChip(_WalletTypeOption option, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = option.value;
        });
      },
      borderRadius: BorderRadius.circular(32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2D8CFF), Color(0xFF40A9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.neutral.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              option.icon,
              size: 18,
              color: isSelected ? AppColors.surface : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              option.label,
              style: AppTextStyles.roboto16w400.copyWith(
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconItem({
    required _WalletIconOption item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: AppIcon(
          item.icon,
          size: 22,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
