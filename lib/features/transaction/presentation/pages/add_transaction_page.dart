import 'package:flutter/material.dart';
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

class AddTransactionPage extends GetView<TransactionController> {
  final TransactionEntity? transactionToEdit;
  const AddTransactionPage({super.key, this.transactionToEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          transactionToEdit != null ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s12),
            Expanded(
              child: _AddTransactionForm(
                controller: controller,
                transactionToEdit: transactionToEdit,
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

  const _AddTransactionForm({required this.controller, this.transactionToEdit});

  @override
  State<_AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  String _amountStr = '0';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
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

      // Restore date; if time string is available, combine it back
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

      // We must set the selected type and wait for categories to load,
      // then set the selected category.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.controller.changeType(t.type);
        await widget.controller.selectCategoryById(
          t.categoryId ?? t.category?.id,
        );
      });
    }
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
                          const Icon(
                            Icons.edit_note,
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
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s24),
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
                  const SizedBox(height: AppSpacing.s16),
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

    final note = _noteController.text.trim();
    final title = _titleController.text.trim();
    final finalNote = [title, note].where((e) => e.isNotEmpty).join(' - ');

    // Extract time string HH:mm:ss from the selected date
    final timeStr =
        '${_selectedDate.hour.toString().padLeft(2, '0')}:'
        '${_selectedDate.minute.toString().padLeft(2, '0')}:00';

    bool success;
    if (widget.transactionToEdit != null) {
      success = await widget.controller.updateTransaction(
        id: widget.transactionToEdit!.id,
        type: widget.controller.selectedType,
        amount: amount,
        categoryId: widget.controller.resolvedSelectedCategoryId,
        note: finalNote.isEmpty ? null : finalNote,
        date: _selectedDate,
        time: timeStr,
      );
    } else {
      success = await widget.controller.addTransaction(
        type: widget.controller.selectedType,
        amount: amount,
        categoryId: widget.controller.resolvedSelectedCategoryId,
        note: finalNote.isEmpty ? null : finalNote,
        date: _selectedDate,
        time: timeStr,
      );
    }

    if (success) {
      Get.back();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTypeToggle(),
                const SizedBox(height: AppSpacing.s24),
                _buildCategories(),
                const SizedBox(height: AppSpacing.s24),
                const Text(
                  'Jumlah',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                _buildAmountDisplay(),
                const SizedBox(height: AppSpacing.s24),
                _buildInputs(),
                const SizedBox(height: AppSpacing.s24),
              ],
            ),
          ),
        ),
        _buildNumpad(),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildToggleBtn('expense', 'Pengeluaran')),
                  Expanded(child: _buildToggleBtn('income', 'Pemasukan')),
                ],
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
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

  Widget _buildCategories() {
    return Obx(() {
      if (widget.controller.isLoading || widget.controller.isCategoryLoading) {
        return const SizedBox(height: 118);
      }

      final parentCategories = widget.controller.parentCategories;
      final childCategories = widget.controller.childCategories;
      final selectedParentId = widget.controller.selectedParentCategory?.id;
      final selectedChildId = widget.controller.selectedChildCategory?.id;

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
                final isSelected = selectedParentId == category.id;
                return _ParentCategoryItem(
                  category: category,
                  isSelected: isSelected,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Rp',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formattedAmount,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInputs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showDetailsPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s12),
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
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showDetailsPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notes,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s12),
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
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s16,
      ),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumBtn('1'),
              _buildNumBtn('2'),
              _buildNumBtn('3'),
              _buildNumBtn(
                'DEL',
                isAction: true,
                bgColor: AppColors.numpadDeleteBg,
                icon: Icons.backspace_outlined,
                iconColor: AppColors.numpadDeleteIcon,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumBtn('4'),
              _buildNumBtn('5'),
              _buildNumBtn('6'),
              const SizedBox(width: 75, height: 60),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumBtn('7'),
              _buildNumBtn('8'),
              _buildNumBtn('9'),
              _buildNumBtn(
                'DATE',
                isAction: true,
                bgColor: AppColors.numpadButtonBg,
                customWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM dd', 'id_ID').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                onTap: _pickDate,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumBtn('.'),
              _buildNumBtn('0'),
              _buildNumBtn('000'),
              Obx(() {
                final isSubmitting = widget.controller.isSubmitting;
                return _buildNumBtn(
                  'SUBMIT',
                  isAction: true,
                  bgColor: AppColors.numpadSubmitBg,
                  customWidget: isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.surface,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.check,
                          color: AppColors.surface,
                          size: 28,
                        ),
                  onTap: _handleSave,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumBtn(
    String value, {
    bool isAction = false,
    Color? bgColor,
    IconData? icon,
    Color? iconColor,
    Widget? customWidget,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => _onNumpadTap(value),
      child: Container(
        width: 75,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.numpadButtonBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (bgColor == AppColors.numpadButtonBg ||
                bgColor == AppColors.numpadActionBg)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child:
              customWidget ??
              (icon != null
                  ? Icon(
                      icon,
                      color: iconColor ?? AppColors.textPrimary,
                      size: 24,
                    )
                  : Text(
                      isAction ? (value == '+-=' ? '+-\nx=' : value) : value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isAction ? 16 : 28,
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
  final bool isSelected;
  final VoidCallback onTap;

  const _ParentCategoryItem({
    required this.category,
    required this.isSelected,
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
                color: isSelected
                    ? color
                    : Color.alphaBlend(
                        color.withValues(alpha: 0.08),
                        AppColors.surface,
                      ),
                border: isSelected
                    ? null
                    : Border.all(color: color.withValues(alpha: 0.18)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.surface : color,
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.roboto12w400.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
    final parentColor = CategoryColorParser.parse(
      parentCategory?.color,
    );
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
              color: isSelected ? chipColor : AppColors.neutral,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
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
                  color: isSelected
                      ? AppColors.surface
                      : AppColors.textPrimary,
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
    final startDay = today.subtract(
      const Duration(days: 365 * 10),
    ); // 10 years back
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
      _selectedDateIndex = 365 * 10; // fallback to today
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
          // Header
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
          // Pickers
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.s16),
                // Date Picker
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
                // Hour Picker
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
                // Minute Picker
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
