import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/category_entity.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/category_chip_widget.dart';
import '../widgets/transaction_type_toggle_widget.dart';

class AddTransactionPage extends GetView<TransactionController> {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tambah Transaksi', style: AppTextStyles.roboto18w500),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _AddTransactionForm(controller: controller),
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
  static const int _dateRangeYears = 5;
  static const int _shimmerItemCount = 6;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - _dateRangeYears),
      lastDate: DateTime(now.year + _dateRangeYears),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  double _parseAmount() {
    final String raw = _amountController.text.trim();
    final String normalized = raw.replaceAll(',', '').replaceAll(' ', '');
    return double.tryParse(normalized) ?? 0;
  }

  Future<void> _handleSave() async {
    if (widget.controller.isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    final double amount = _parseAmount();
    if (amount <= 0) {
      Get.snackbar('Error', 'Nominal wajib diisi dan harus lebih dari 0');
      return;
    }

    if (widget.controller.selectedCategory == null) {
      Get.snackbar('Error', 'Pilih kategori terlebih dahulu');
      return;
    }

    final String previousError = widget.controller.errorMessage;
    final String note = _noteController.text.trim();

    await widget.controller.addTransaction(
      type: widget.controller.selectedType,
      amount: amount,
      categoryId: widget.controller.selectedCategory?.id,
      note: note.isEmpty ? null : note,
      date: _selectedDate,
    );

    if (widget.controller.errorMessage == previousError) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => TransactionTypeToggleWidget(
                selectedType: widget.controller.selectedType,
                onChanged: widget.controller.changeType,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.lora36w400,
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: AppTextStyles.lora36w400,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Obx(() {
              if (widget.controller.isLoading) {
                return _buildCategoryShimmer();
              }

              final List<CategoryEntity> categories =
                  widget.controller.categories;
              final String? selectedId = widget.controller.selectedCategory?.id;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.s12,
                  mainAxisSpacing: AppSpacing.s12,
                  childAspectRatio: AppSpacing.s48 / AppSpacing.s16,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return CategoryChipWidget(
                    category: category,
                    isSelected: category.id == selectedId,
                    onTap: () => widget.controller.selectCategory(category),
                  );
                },
              );
            }),
            const SizedBox(height: AppSpacing.s24),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              style: AppTextStyles.roboto14w400,
              decoration: InputDecoration(
                hintText: 'Catatan (opsional)',
                hintStyle: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.all(AppSpacing.s12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.s8),
                  borderSide: const BorderSide(color: AppColors.neutral),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.s8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s12,
                  horizontal: AppSpacing.s16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.neutral),
                  borderRadius: BorderRadius.circular(AppSpacing.s8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tanggal',
                      style: AppTextStyles.roboto14w400.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: AppTextStyles.roboto14w400,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Obx(() {
              final bool isSubmitting = widget.controller.isSubmitting;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.s8),
                    ),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: AppSpacing.s16,
                          height: AppSpacing.s16,
                          child: const CircularProgressIndicator(
                            strokeWidth: AppSpacing.s4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.surface,
                            ),
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: AppTextStyles.roboto16w400.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.s12,
        mainAxisSpacing: AppSpacing.s12,
        childAspectRatio: AppSpacing.s48 / AppSpacing.s16,
      ),
      itemCount: _shimmerItemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.background,
          highlightColor: AppColors.surface,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.s8),
              border: Border.all(color: AppColors.neutral),
            ),
          ),
        );
      },
    );
  }
}
