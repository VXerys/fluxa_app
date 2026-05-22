import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/wallet_controller.dart';

class _WalletTypeOption {
  final String label;
  final String value;
  final IconData icon;

  const _WalletTypeOption({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _WalletIconOption {
  final String key;
  final IconData icon;

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
    _WalletTypeOption(
      label: 'Bank',
      value: 'bank',
      icon: Icons.account_balance_outlined,
    ),
    _WalletTypeOption(
      label: 'E-Wallet',
      value: 'ewallet',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _WalletTypeOption(
      label: 'Kas',
      value: 'cash',
      icon: Icons.payments_outlined,
    ),
  ];

  static const List<_WalletIconOption> _iconOptions = <_WalletIconOption>[
    _WalletIconOption(
      key: 'wallet_01',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _WalletIconOption(key: 'wallet_02', icon: Icons.account_balance_outlined),
    _WalletIconOption(key: 'wallet_03', icon: Icons.credit_card_outlined),
    _WalletIconOption(key: 'wallet_04', icon: Icons.request_quote_outlined),
    _WalletIconOption(key: 'wallet_05', icon: Icons.savings_outlined),
    _WalletIconOption(key: 'wallet_06', icon: Icons.attach_money_outlined),
    _WalletIconOption(
      key: 'wallet_07',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _WalletIconOption(key: 'wallet_08', icon: Icons.sync_alt_outlined),
    _WalletIconOption(key: 'wallet_09', icon: Icons.badge_outlined),
    _WalletIconOption(key: 'wallet_10', icon: Icons.swap_horiz_outlined),
    _WalletIconOption(key: 'wallet_11', icon: Icons.trending_up_outlined),
    _WalletIconOption(key: 'wallet_12', icon: Icons.receipt_long_outlined),
    _WalletIconOption(key: 'wallet_13', icon: Icons.currency_bitcoin_outlined),
    _WalletIconOption(key: 'wallet_14', icon: Icons.description_outlined),
    _WalletIconOption(key: 'wallet_15', icon: Icons.shopping_bag_outlined),
    _WalletIconOption(key: 'wallet_16', icon: Icons.shopping_cart_outlined),
    _WalletIconOption(key: 'wallet_17', icon: Icons.storefront_outlined),
    _WalletIconOption(key: 'wallet_18', icon: Icons.store_outlined),
    _WalletIconOption(key: 'wallet_19', icon: Icons.card_giftcard_outlined),
    _WalletIconOption(key: 'wallet_20', icon: Icons.redeem_outlined),
    _WalletIconOption(key: 'wallet_21', icon: Icons.bookmark_border_outlined),
    _WalletIconOption(key: 'wallet_22', icon: Icons.checkroom_outlined),
    _WalletIconOption(key: 'wallet_23', icon: Icons.local_mall_outlined),
    _WalletIconOption(key: 'wallet_24', icon: Icons.directions_car_outlined),
    _WalletIconOption(key: 'wallet_25', icon: Icons.train_outlined),
    _WalletIconOption(key: 'wallet_26', icon: Icons.flight_outlined),
    _WalletIconOption(
      key: 'wallet_27',
      icon: Icons.directions_railway_outlined,
    ),
    _WalletIconOption(key: 'wallet_28', icon: Icons.directions_bus_outlined),
    _WalletIconOption(key: 'wallet_29', icon: Icons.pedal_bike_outlined),
    _WalletIconOption(key: 'wallet_30', icon: Icons.waves_outlined),
    _WalletIconOption(key: 'wallet_31', icon: Icons.medical_services_outlined),
    _WalletIconOption(key: 'wallet_32', icon: Icons.local_hospital),
    _WalletIconOption(key: 'wallet_33', icon: Icons.wifi_outlined),
    _WalletIconOption(key: 'wallet_34', icon: Icons.flash_on_outlined),
    _WalletIconOption(key: 'wallet_35', icon: Icons.restaurant_outlined),
    _WalletIconOption(key: 'wallet_36', icon: Icons.local_cafe_outlined),
    _WalletIconOption(key: 'wallet_37', icon: Icons.cake_outlined),
    _WalletIconOption(key: 'wallet_38', icon: Icons.icecream_outlined),
    _WalletIconOption(key: 'wallet_39', icon: Icons.fastfood_outlined),
    _WalletIconOption(key: 'wallet_40', icon: Icons.sports_esports_outlined),
    _WalletIconOption(key: 'wallet_41', icon: Icons.music_note_outlined),
    _WalletIconOption(key: 'wallet_42', icon: Icons.photo_camera_outlined),
    _WalletIconOption(key: 'wallet_43', icon: Icons.sports_basketball_outlined),
    _WalletIconOption(key: 'wallet_44', icon: Icons.sports_tennis_outlined),
    _WalletIconOption(key: 'wallet_45', icon: Icons.sports_golf_outlined),
    _WalletIconOption(key: 'wallet_46', icon: Icons.sports_soccer_outlined),
    _WalletIconOption(key: 'wallet_47', icon: Icons.beach_access_outlined),
    _WalletIconOption(key: 'wallet_48', icon: Icons.self_improvement),
  ];

  final WalletController _controller = Get.find<WalletController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  String _selectedType = 'bank';
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
                    icon: const Icon(
                      Icons.arrow_back,
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
                      style: AppTextStyles.roboto18w600.copyWith(
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
                            : const Icon(
                                Icons.check,
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
                      style: AppTextStyles.roboto18w600.copyWith(
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
                          color: AppColors.neutral.withOpacity(0.14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.public_outlined,
                              size: 22,
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
                          color: AppColors.neutral.withOpacity(0.14),
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
      style: AppTextStyles.roboto16w600.copyWith(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
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
        color: AppColors.textSecondary.withOpacity(0.72),
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
        borderSide: BorderSide(color: AppColors.neutral.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.s16),
        borderSide: BorderSide(color: AppColors.neutral.withOpacity(0.12)),
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
                : AppColors.neutral.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
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
        child: Icon(
          item.icon,
          size: 22,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
