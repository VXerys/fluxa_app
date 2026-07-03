import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/category_color_parser.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controllers/transaction_controller.dart';
import '../../../voice_transaction/domain/entities/voice_transaction_draft_params.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionEntity? transactionToEdit;
  const AddTransactionPage({super.key, this.transactionToEdit});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isClosing = false;
  late final TransactionController controller;
  late final WalletController walletController;
  late final VoiceTransactionDraftParams? voiceDraft;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TransactionController>();
    walletController = Get.find<WalletController>();
    final dynamic routeArguments = Get.arguments;
    voiceDraft = routeArguments is VoiceTransactionDraftParams
        ? routeArguments
        : null;
    if (walletController.wallets.isEmpty && !walletController.isLoading) {
      walletController.loadWallets();
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _close([bool? result]) {
    if (_isClosing) return;
    setState(() {
      _isClosing = true;
    });
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: PopScope(
        canPop: _isClosing,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _close();
        },
        child: Stack(
          children: [
            // Background Tap dismisses the modal
            GestureDetector(
              onTap: _close,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            // Content sheet sliding from bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Modal handle
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.neutral.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Form
                      Expanded(
                        child: _AddTransactionForm(
                          controller: controller,
                          transactionToEdit: widget.transactionToEdit,
                          voiceDraft: voiceDraft,
                          onClose: _close,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTransactionForm extends StatefulWidget {
  final TransactionController controller;
  final TransactionEntity? transactionToEdit;
  final VoiceTransactionDraftParams? voiceDraft;
  final ValueChanged<bool?> onClose;

  const _AddTransactionForm({
    required this.controller,
    this.transactionToEdit,
    this.voiceDraft,
    required this.onClose,
  });

  @override
  State<_AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  String _amountStr = '0';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedWalletId;
  // ignore: unused_field
  String _selectedWallet = 'Pilih dompet';

  @override
  void initState() {
    super.initState();
    final walletController = Get.find<WalletController>();
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _amountStr = t.amount.toInt().toString();

      // Parse note into title and note if separated by " - "
      if (t.note != null && t.note!.contains(' - ')) {
        final parts = t.note!.split(' - ');
        _titleController.text = parts.first;
        _noteController.text = parts.sublist(1).join(' - ');
      } else {
        _titleController.text = t.note ?? '';
      }

      // Restore date; combine time if available
      DateTime baseDate = t.date;
      if (t.time != null && t.time!.isNotEmpty) {
        final timeParts = t.time!.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          baseDate = DateTime(
            t.date.year,
            t.date.month,
            t.date.day,
            hour,
            minute,
          );
        }
      }
      _selectedDate = baseDate;
      _selectedWalletId = t.walletId;
      _selectedWallet = t.walletName ?? 'Pilih dompet';

      // We must set the selected type and wait for categories to load,
      // then set the selected category.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.controller.changeType(t.type);
        await widget.controller.selectCategoryById(
          t.categoryId ?? t.category?.id,
        );
        await _syncWalletSelection(walletController);
      });
    } else if (widget.voiceDraft != null) {
      final VoiceTransactionDraftParams draft = widget.voiceDraft!;
      _amountStr = _formatInitialAmount(draft.amount);
      _titleController.text = draft.displayTitle ?? '';
      _noteController.text =
          draft.displayDescription != draft.displayTitle
          ? (draft.displayDescription ?? '')
          : '';
      _selectedDate = draft.occurredAt;
      _selectedWalletId = draft.walletId;
      _selectedWallet = draft.displayWallet ?? 'Pilih dompet';

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final String draftType =
            draft.type == 'income' || draft.type == 'expense'
            ? draft.type!
            : widget.controller.selectedType;
        await widget.controller.changeType(draftType);
        await widget.controller.selectCategoryById(
          draft.resolvedTransactionCategoryId,
        );
        await _syncWalletSelection(walletController);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _syncWalletSelection(walletController);
      });
    }
  }

  String _formatInitialAmount(double? amount) {
    if (amount == null || amount <= 0) return '0';
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }

  Future<void> _syncWalletSelection(WalletController walletController) async {
    if (walletController.wallets.isEmpty && !walletController.isLoading) {
      await walletController.loadWallets();
    }

    if (!mounted) return;

    final wallets = walletController.wallets;
    if (wallets.isEmpty) return;

    if (_selectedWalletId != null) {
      WalletEntity? matched;
      for (final wallet in wallets) {
        if (wallet.id == _selectedWalletId) {
          matched = wallet;
          break;
        }
      }
      if (matched != null) {
        final walletName = matched.name;
        setState(() {
          _selectedWallet = walletName;
        });
        return;
      }
    }

    final fallbackWallet = wallets.first;
    setState(() {
      _selectedWalletId = fallbackWallet.id;
      _selectedWallet = fallbackWallet.name;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showDetailsPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const AppIcon(
                            AppHugeIcons.edit_note,
                            color: AppColors.textPrimary,
                            size: 28,
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          const Text(
                            'Detail Transaksi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const AppIcon(
                          AppHugeIcons.close,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  const Text(
                    'Judul',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Belanja Bulanan',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s16,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const Text(
                    'Catatan',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s16,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Konfirmasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onNumpadTap(String value) {
    setState(() {
      if (value == 'DEL') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (value == '000') {
        if (_amountStr != '0') {
          _amountStr += '000';
        }
      } else if (value == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = value;
        } else {
          _amountStr += value;
        }
      }
    });
  }

  void _handleSave() async {
    final double amount = double.tryParse(_amountStr) ?? 0;
    if (amount <= 0) {
      Get.snackbar('Error', 'Nominal harus lebih dari 0');
      return;
    }
    if (widget.controller.resolvedSelectedCategoryId == null) {
      Get.snackbar('Error', 'Pilih kategori terlebih dahulu');
      return;
    }
    if (_selectedWalletId == null || _selectedWalletId!.isEmpty) {
      Get.snackbar('Error', 'Pilih dompet terlebih dahulu');
      return;
    }

    final note = _noteController.text.trim();
    final title = _titleController.text.trim();
    final finalNote = [title, note].where((e) => e.isNotEmpty).join(' - ');

    // Extract time string HH:mm:ss from selected date
    final timeStr =
        '${_selectedDate.hour.toString().padLeft(2, '0')}:'
        '${_selectedDate.minute.toString().padLeft(2, '0')}:00';

    bool success;
    if (widget.transactionToEdit != null) {
      success = await widget.controller.updateTransaction(
        id: widget.transactionToEdit!.id,
        type: widget.controller.selectedType,
        amount: amount,
        walletId: _selectedWalletId!,
        categoryId: widget.controller.resolvedSelectedCategoryId,
        note: finalNote.isEmpty ? null : finalNote,
        date: _selectedDate,
        time: timeStr,
      );
    } else {
      success = await widget.controller.addTransaction(
        type: widget.controller.selectedType,
        amount: amount,
        walletId: _selectedWalletId!,
        categoryId: widget.controller.resolvedSelectedCategoryId,
        note: finalNote.isEmpty ? null : finalNote,
        date: _selectedDate,
        time: timeStr,
      );
    }

    if (success) {
      widget.onClose(true);
    }
  }

  Future<void> _pickDate() async {
    await Get.bottomSheet(
      CustomDateTimePickerSheet(
        initialDate: _selectedDate,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ignore: unused_element
  void _showWalletSelector() {
    final walletController = Get.find<WalletController>();
    Get.bottomSheet(
      Obx(
        () => Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pilih Dompet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (walletController.wallets.isEmpty)
                Text(
                  walletController.isLoading
                      ? 'Memuat dompet...'
                      : 'Belum ada dompet aktif',
                  style: AppTextStyles.roboto14w400.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else
                ...walletController.wallets.map(_buildWalletItem),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildWalletItem(WalletEntity wallet) {
    final isSelected = _selectedWalletId == wallet.id;
    return ListTile(
      leading: AppIcon(
        _walletIconByType(wallet.type),
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        wallet.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${wallet.type.toUpperCase()} • ${wallet.currency}',
        style: AppTextStyles.roboto12w400.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: isSelected
          ? const AppIcon(AppHugeIcons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() {
          _selectedWalletId = wallet.id;
          _selectedWallet = wallet.name;
        });
        Get.back();
      },
    );
  }

  AppIconData _walletIconByType(String type) {
    switch (type) {
      case 'bank':
        return AppHugeIcons.account_balance_outlined;
      case 'ewallet':
        return AppHugeIcons.phone_android_outlined;
      case 'credit':
        return AppHugeIcons.credit_card_outlined;
      case 'savings':
        return AppHugeIcons.savings_outlined;
      case 'investment':
        return AppHugeIcons.show_chart_outlined;
      case 'cash':
      default:
        return AppHugeIcons.account_balance_wallet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildTypeToggle(),
                const SizedBox(height: 20),
                _buildCategories(),
                const SizedBox(height: 16),
                const Text(
                  'Jumlah',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                _buildAmountDisplay(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_buildInputs(), _buildNumpad()],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildToggleBtn('expense', 'Pengeluaran')),
                  Expanded(child: _buildToggleBtn('income', 'Pemasukan')),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Camera scan button (Mockup)
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'Pindai Resi',
                'Fitur OCR struk belanja akan segera hadir!',
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.15),
                ),
              ),
              child: const AppIcon(
                AppHugeIcons.camera_alt_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String type, String label, {bool disabled = false}) {
    return Obx(() {
      final isSelected = widget.controller.selectedType == type;
      final isDisabled = disabled || widget.controller.isCategoryLoading;
      return GestureDetector(
        onTap: isDisabled ? null : () => widget.controller.changeType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.surface : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent Categories Shimmer
        SizedBox(
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            itemCount: 5,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ShimmerPlaceholder(
                      width: 52,
                      height: 52,
                      borderRadius: 26,
                    ),
                    SizedBox(height: 6),
                    _ShimmerPlaceholder(width: 55, height: 12, borderRadius: 4),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        // Child Categories Shimmer
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            itemCount: 4,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(right: AppSpacing.s8),
                child: _ShimmerPlaceholder(
                  width: 90,
                  height: 44,
                  borderRadius: 22,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Obx(() {
      final parentCategories = widget.controller.parentCategories;
      final childCategories = widget.controller.childCategories;
      final selectedParentId = widget.controller.selectedParentCategory?.id;
      final selectedChildId = widget.controller.selectedChildCategory?.id;

      // Show shimmer ONLY if categories are empty AND loading
      if (parentCategories.isEmpty && widget.controller.isCategoryLoading) {
        return _buildShimmerLoading();
      }

      if (parentCategories.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Text(
            'Kategori belum tersedia',
            style: AppTextStyles.roboto14w400.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 82,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              itemCount: parentCategories.length,
              itemBuilder: (context, index) {
                final category = parentCategories[index];
                final isFocused = selectedParentId == category.id;
                final isSelectedAsActive =
                    isFocused &&
                    widget.controller.categoryConfirmedByUser &&
                    widget.controller.selectedChildCategory == null;
                return _ParentCategoryItem(
                  category: category,
                  isFocused: isFocused,
                  isSelectedAsActive: isSelectedAsActive,
                  onTap: () => widget.controller.selectParentCategory(category),
                );
              },
            ),
          ),
          if (childCategories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                itemCount: childCategories.length,
                itemBuilder: (context, index) {
                  final category = childCategories[index];
                  final parentCategory =
                      widget.controller.selectedParentCategory;
                  final isSelected = selectedChildId == category.id;
                  return _ChildCategoryChip(
                    key: ValueKey(category.id),
                    category: category,
                    parentCategory: parentCategory,
                    isSelected: isSelected,
                    onTap: () {
                      final wasSelected = isSelected;
                      widget.controller.selectChildCategory(category);
                      final isSelectedAfter =
                          widget.controller.selectedChildCategory?.id ==
                          category.id;
                      debugPrint(
                        'Child chip tap: name=${category.name}, '
                        'childColor=${category.color}, '
                        'parentColor=${parentCategory?.color}, '
                        'isSelectedBefore=$wasSelected, '
                        'isSelectedAfter=$isSelectedAfter',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildAmountDisplay() {
    String formattedAmount = _amountStr;
    if (formattedAmount.length > 3 && !formattedAmount.contains('.')) {
      final doubleval = double.tryParse(_amountStr) ?? 0;
      formattedAmount = NumberFormat.decimalPattern('id_ID').format(doubleval);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Dropdown Rp selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neutral.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Rp',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Amount
        Text(
          formattedAmount,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        // Blinking cursor visual
        const Text(
          '|',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w200,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInputs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Column(
        children: [
          // Judul Field
          GestureDetector(
            onTap: _showDetailsPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  const AppIcon(
                    AppHugeIcons.description_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _titleController.text.isNotEmpty
                          ? _titleController.text
                          : 'Judul',
                      style: TextStyle(
                        color: _titleController.text.isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Catatan (Wallet Selector Dropdown Row hidden)
          Row(
            children: [
              // Catatan
              Expanded(
                child: GestureDetector(
                  onTap: _showDetailsPopup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.neutral.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const AppIcon(
                          AppHugeIcons.edit_note,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _noteController.text.isNotEmpty
                                ? _noteController.text
                                : 'Tambah catatan...',
                            style: TextStyle(
                              color: _noteController.text.isNotEmpty
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: 12,
      ),
      color: AppColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column 1: 1, 4, 7, .
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNumBtn('1'),
                const SizedBox(height: 8),
                _buildNumBtn('4'),
                const SizedBox(height: 8),
                _buildNumBtn('7'),
                const SizedBox(height: 8),
                _buildNumBtn('.'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Column 2: 2, 5, 8, 0
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNumBtn('2'),
                const SizedBox(height: 8),
                _buildNumBtn('5'),
                const SizedBox(height: 8),
                _buildNumBtn('8'),
                const SizedBox(height: 8),
                _buildNumBtn('0'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Column 3: 3, 6, 9, 000
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNumBtn('3'),
                const SizedBox(height: 8),
                _buildNumBtn('6'),
                const SizedBox(height: 8),
                _buildNumBtn('9'),
                const SizedBox(height: 8),
                _buildNumBtn('000'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Column 4: DEL, DATE, SUBMIT
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNumBtn(
                  'DEL',
                  isAction: true,
                  bgColor: AppColors.numpadDeleteBg,
                  icon: AppHugeIcons.backspace_outlined,
                  iconColor: AppColors.numpadDeleteIcon,
                ),
                const SizedBox(height: 8),
                _buildNumBtn(
                  'DATE',
                  isAction: true,
                  bgColor: AppColors.numpadActionBg,
                  customWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM dd', 'id_ID').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final isSubmitting = widget.controller.isSubmitting;
                  return _buildNumBtn(
                    'SUBMIT',
                    isAction: true,
                    height: 116,
                    bgColor: AppColors.numpadSubmitBg,
                    customWidget: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.surface,
                              strokeWidth: 2,
                            ),
                          )
                        : const AppIcon(
                            AppHugeIcons.check,
                            color: AppColors.surface,
                            size: 24,
                          ),
                    onTap: _handleSave,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumBtn(
    String value, {
    bool isAction = false,
    double height = 54,
    Color? bgColor,
    AppIconData? icon,
    Color? iconColor,
    Widget? customWidget,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => _onNumpadTap(value),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.numpadButtonBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (bgColor == null || bgColor == AppColors.numpadButtonBg)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1.5),
              ),
          ],
        ),
        child: Center(
          child:
              customWidget ??
              (icon != null
                  ? AppIcon(
                      icon,
                      color: iconColor ?? AppColors.textPrimary,
                      size: 20,
                    )
                  : Text(
                      value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isAction ? 14 : 22,
                        fontWeight: isAction
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    )),
        ),
      ),
    );
  }
}

class _ParentCategoryItem extends StatelessWidget {
  final CategoryEntity category;
  final bool isFocused;
  final bool isSelectedAsActive;
  final VoidCallback onTap;

  const _ParentCategoryItem({
    required this.category,
    required this.isFocused,
    required this.isSelectedAsActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = CategoryColorParser.parse(category.color);
    final icon = CategoryIconMapper.fromKey(category.icon);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFocused
                    ? color
                    : Color.alphaBlend(
                        color.withValues(alpha: 0.06),
                        AppColors.background,
                      ),
                border: isFocused
                    ? null
                    : Border.all(
                        color: color.withValues(alpha: 0.18),
                        width: 1,
                      ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: AppIcon(
                icon,
                size: 24,
                color: isFocused ? AppColors.surface : color,
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.roboto12w400.copyWith(
                color: isFocused
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isFocused
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final CategoryEntity? parentCategory;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildCategoryChip({
    super.key,
    required this.category,
    this.parentCategory,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parentColor = CategoryColorParser.parse(parentCategory?.color);
    final colorSource = category.color ?? parentCategory?.color;

    final chipColor = CategoryColorParser.parse(
      colorSource,
      fallback: parentColor,
    );

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.s24),
            border: Border.all(
              color: isSelected
                  ? chipColor
                  : AppColors.neutral.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                CategoryIconMapper.fromKey(category.icon),
                size: 18,
                color: isSelected ? AppColors.surface : chipColor,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.roboto14w400.copyWith(
                  color: isSelected ? AppColors.surface : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDateTimePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomDateTimePickerSheet({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<CustomDateTimePickerSheet> createState() =>
      _CustomDateTimePickerSheetState();
}

class _CustomDateTimePickerSheetState extends State<CustomDateTimePickerSheet> {
  late FixedExtentScrollController _dateController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  late List<DateTime> _dates;
  late int _selectedDateIndex;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialDate.hour;
    _selectedMinute = widget.initialDate.minute;

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final startDay = today.subtract(const Duration(days: 365 * 10));
    _dates = List.generate(
      365 * 20 + 1,
      (index) => startDay.add(Duration(days: index)),
    );

    _selectedDateIndex = _dates.indexWhere(
      (d) =>
          d.year == widget.initialDate.year &&
          d.month == widget.initialDate.month &&
          d.day == widget.initialDate.day,
    );

    if (_selectedDateIndex == -1) {
      _selectedDateIndex = 365 * 10;
    }

    _dateController = FixedExtentScrollController(
      initialItem: _selectedDateIndex,
    );
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _dates[_selectedDateIndex];
    final today = DateTime.now();

    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Color(0xFF1B496B),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  '${selectedDate.year}',
                  style: const TextStyle(
                    color: Color(0xFF1B496B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final finalDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      _selectedHour,
                      _selectedMinute,
                    );
                    widget.onDateSelected(finalDate);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Color(0xFF1B496B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  flex: 4,
                  child: _buildPicker(
                    controller: _dateController,
                    itemCount: _dates.length,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedDateIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final date = _dates[index];
                      final isToday = _isSameDay(date, today);
                      String text;
                      if (isToday) {
                        text = 'Hari Ini';
                      } else {
                        text = DateFormat('EEE MMM dd', 'id_ID').format(date);
                      }
                      return Center(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildPicker(
                    controller: _hourController,
                    itemCount: 24,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedHour = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildPicker(
                    controller: _minuteController,
                    itemCount: 60,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMinute = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: 40,
      useMagnifier: false,
      selectionOverlay: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.neutral.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onSelectedItemChanged: onSelectedItemChanged,
      childCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerPlaceholder({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.35 + (_controller.value * 0.45),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}





