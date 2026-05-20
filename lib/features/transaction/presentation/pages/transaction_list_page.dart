import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_filter_widget.dart';
import '../widgets/transaction_item_widget.dart';

class TransactionListPage extends GetView<TransactionController> {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Transaksi', style: AppTextStyles.roboto18w500),
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _TransactionListBody(controller: controller),
    );
  }
}

class _TransactionListBody extends StatefulWidget {
  final TransactionController controller;

  const _TransactionListBody({required this.controller});

  @override
  State<_TransactionListBody> createState() => _TransactionListBodyState();
}

class _TransactionListBodyState extends State<_TransactionListBody> {
  String _selectedFilter = 'Semua';

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<TransactionEntity> _applyFilter(List<TransactionEntity> items) {
    final List<TransactionEntity> sorted = List.from(items)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (_selectedFilter == 'Pemasukan') {
      return sorted.where((item) => item.type == 'income').toList();
    }
    if (_selectedFilter == 'Pengeluaran') {
      return sorted.where((item) => item.type == 'expense').toList();
    }
    return sorted;
  }

  Future<void> _confirmDelete(TransactionEntity transaction) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Transaksi', style: AppTextStyles.roboto16w400),
          content: Text(
            'Transaksi ini akan dihapus. Lanjutkan?',
            style: AppTextStyles.roboto14w400,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text('Batal', style: AppTextStyles.roboto14w400),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text('Hapus', style: AppTextStyles.roboto14w400),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget.controller.deleteTransaction(transaction.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isLoading) {
        return _buildShimmerList();
      }

      if (widget.controller.transactions.isEmpty) {
        return const AppEmptyStateWidget(message: 'Belum ada transaksi');
      }

      final List<TransactionEntity> filtered = _applyFilter(
        widget.controller.transactions,
      );

      return Column(
        children: [
          TransactionFilterWidget(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),
          const SizedBox(height: AppSpacing.s8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.controller.loadTransactions,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.s8),
                itemBuilder: (context, index) {
                  final transaction = filtered[index];

                  return GestureDetector(
                    onLongPress: () => _confirmDelete(transaction),
                    child: TransactionItemWidget(transaction: transaction),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.background,
          highlightColor: AppColors.surface,
          child: Container(
            height: AppSpacing.s48 + AppSpacing.s16,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.s12),
            ),
          ),
        );
      },
    );
  }
}

class AppEmptyStateWidget extends StatelessWidget {
  final String message;

  const AppEmptyStateWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.roboto14w400.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
