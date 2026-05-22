import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_item_widget.dart';
import 'transaction_detail_page.dart';
import 'transaction_list_page.dart';

class TransactionTypeDetailPage extends StatefulWidget {
  final bool isIncome;
  
  const TransactionTypeDetailPage({
    super.key,
    required this.isIncome,
  });

  @override
  State<TransactionTypeDetailPage> createState() => _TransactionTypeDetailPageState();
}

class _TransactionTypeDetailPageState extends State<TransactionTypeDetailPage> {
  late final TransactionController controller;
  List<TransactionEntity> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TransactionController>();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 1);
    
    final params = GetTransactionsParams(
      type: widget.isIncome ? 'income' : 'expense',
      startDate: startDate,
      endDate: endDate,
      sortBy: 'dateDesc',
    );

    final result = await controller.getTransactionsUseCase(params);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        result.fold(
          (failure) => _transactions = [],
          (data) => _transactions = data,
        );
      });
    }
  }

  String _formatAmount(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: widget.isIncome ? 'Rp' : '-Rp',
      decimalDigits: 2,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isIncome ? 'Detail Pemasukan' : 'Detail Pengeluaran';

    return Scaffold(
      backgroundColor: AppColors.background, // Menggunakan background color yang sesuai
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              title,
              style: AppTextStyles.roboto18w600.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Bulan Ini',
              style: AppTextStyles.roboto12w400.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(
            AppHugeIcons.arrow_back,
            color: AppColors.textPrimary,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Builder(builder: (context) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalAmount = _transactions.fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );

        if (_transactions.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s24,
                vertical: AppSpacing.s16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaksi Terakhir',
                        style: AppTextStyles.roboto18w600.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(DateTime.now()),
                        style: AppTextStyles.roboto14w400.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.setFilterType(widget.isIncome ? 'Pemasukan' : 'Pengeluaran');
                          controller.setFilterDateRange('Bulan Ini');
                          Get.to(() => const TransactionListPage());
                        },
                        child: Text(
                          'Lihat Semua',
                          style: AppTextStyles.roboto14w400.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        _formatAmount(totalAmount),
                        style: AppTextStyles.roboto14w400.copyWith(
                          color: widget.isIncome ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s16,
                ),
                itemCount: _transactions.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s16),
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return GestureDetector(
                    onTap: () => Get.to(
                      () => TransactionDetailPage(transaction: transaction),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface, // Card background white
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TransactionItemWidget(transaction: transaction),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
          ],
        );
      }),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            AppHugeIcons.attach_money,
            size: 64,
            color: AppColors.neutral.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            widget.isIncome
                ? 'Tidak ada pemasukan\nuntuk tanggal ini'
                : 'Tidak ada pengeluaran\nuntuk tanggal ini',
            textAlign: TextAlign.center,
            style: AppTextStyles.roboto16w400.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}




