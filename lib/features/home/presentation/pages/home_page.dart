import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../controllers/home_controller.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/recent_transaction_item_widget.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.loadSummary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('~ Hai!', style: AppTextStyles.lora24w400),
              const SizedBox(height: AppSpacing.s16),
              Obx(() => BalanceCardWidget(summary: controller.summary)),
              const SizedBox(height: AppSpacing.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terakhir',
                    style: AppTextStyles.roboto16w400.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.transactionList),
                    child: Text(
                      'Lihat Semua',
                      style: AppTextStyles.roboto14w400.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Obx(() => _buildRecentTransactions(controller)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(HomeController controller) {
    if (controller.isLoading) {
      return _buildRecentShimmer();
    }

    final summary = controller.summary;
    final List<TransactionEntity> recentTransactions =
        summary?.recentTransactions ?? <TransactionEntity>[];

    if (summary == null || recentTransactions.isEmpty) {
      return Text(
        'Belum ada transaksi',
        style: AppTextStyles.roboto14w400.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    final List<TransactionEntity> items = recentTransactions.take(5).toList();

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          RecentTransactionItemWidget(transaction: items[i]),
          if (i < items.length - 1) const SizedBox(height: AppSpacing.s8),
        ],
      ],
    );
  }

  Widget _buildRecentShimmer() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: Shimmer.fromColors(
            baseColor: AppColors.background,
            highlightColor: AppColors.surface,
            child: Container(
              height: AppSpacing.s48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.s12),
              ),
            ),
          ),
        );
      }),
    );
  }
}
