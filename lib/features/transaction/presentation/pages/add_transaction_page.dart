import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/transaction_controller.dart';

class AddTransactionPage extends GetView<TransactionController> {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s12),
            // Fake drag handle for bottom sheet look
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Expanded(child: _AddTransactionForm(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _AddTransactionForm extends StatefulWidget {
  final TransactionController controller;

  const _AddTransactionForm({required this.controller});

  @override
  State<_AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  String _amountStr = '0';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
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
    if (widget.controller.selectedCategory == null) {
      Get.snackbar('Error', 'Pilih kategori terlebih dahulu');
      return;
    }

    final note = _noteController.text.trim();
    final title = _titleController.text.trim();
    final finalNote = [title, note].where((e) => e.isNotEmpty).join(' - ');

    final success = await widget.controller.addTransaction(
      type: widget.controller.selectedType,
      amount: amount,
      categoryId: widget.controller.selectedCategory?.id,
      note: finalNote.isEmpty ? null : finalNote,
      date: _selectedDate,
    );
    if (success) {
      Get.back();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
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
                _buildTypeToggle(),
                const SizedBox(height: AppSpacing.s24),
                _buildCategories(),
                const SizedBox(height: AppSpacing.s24),
                const Text(
                  'Amount',
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
                border: Border.all(color: AppColors.neutral.withOpacity(0.2)),
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
      return GestureDetector(
        onTap: disabled ? null : () => widget.controller.changeType(type),
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
      if (widget.controller.isLoading) return const SizedBox(height: 70);
      final categories = widget.controller.categories;
      return SizedBox(
        height: 75,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = widget.controller.selectedCategory?.id == cat.id;

            // Assign a unique color based on index for variety
            final colors = [
              AppColors.categoryFood,
              AppColors.categoryTransport,
              AppColors.categoryShopping,
              AppColors.categoryHousing,
            ];
            final color = colors[index % colors.length];

            // Map category name to icon
            IconData catIcon = Icons.category_outlined;
            final nameLower = cat.name.toLowerCase();
            if (nameLower.contains('makan') || nameLower.contains('minum')) {
              catIcon = Icons.restaurant_outlined;
            } else if (nameLower.contains('transport')) {
              catIcon = Icons.directions_bus_outlined;
            } else if (nameLower.contains('belanja')) {
              catIcon = Icons.shopping_bag_outlined;
            } else if (nameLower.contains('rumah') ||
                nameLower.contains('tagihan')) {
              catIcon = Icons.home_outlined;
            } else if (nameLower.contains('hiburan')) {
              catIcon = Icons.movie_outlined;
            } else if (nameLower.contains('kesehatan')) {
              catIcon = Icons.medical_services_outlined;
            } else if (nameLower.contains('pendidikan')) {
              catIcon = Icons.school_outlined;
            }

            return GestureDetector(
              onTap: () => widget.controller.selectCategory(cat),
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? color : AppColors.surface,
                        border: isSelected
                            ? null
                            : Border.all(
                                color: AppColors.neutral.withOpacity(0.2),
                              ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Icon(
                          catIcon,
                          size: 24,
                          color: isSelected ? AppColors.surface : color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
            color: AppColors.primary.withOpacity(0.1),
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
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.description_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neutral.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neutral.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Add a note...',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.notes,
                color: AppColors.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neutral.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neutral.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
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
                      DateFormat('MMM dd').format(_selectedDate),
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
                color: Colors.black.withOpacity(0.02),
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
