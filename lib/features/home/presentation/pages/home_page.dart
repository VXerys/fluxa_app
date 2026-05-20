import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../navigation/presentation/controllers/main_navigation_controller.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../controllers/home_controller.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/recent_transaction_item_widget.dart';
import 'package:intl/intl.dart';

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
              _buildMenu(),
              const SizedBox(height: AppSpacing.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terakhir',
                    style: AppTextStyles.roboto16w400.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
              const SizedBox(height: AppSpacing.s16),
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

    String dateHeader = '';
    String totalStr = '';
    
    if (items.isNotEmpty) {
      final firstDate = items.first.date;
      try {
        dateHeader = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(firstDate);
      } catch (_) {
        dateHeader = DateFormat('EEEE, d MMM yyyy').format(firstDate);
      }
      
      double total = 0;
      for(var item in items) {
        if(item.type == 'income') {
          total += item.amount;
        } else {
          total -= item.amount;
        }
      }
      totalStr = NumberFormat.currency(
        locale: 'id_ID',
        symbol: total < 0 ? '-Rp' : '+Rp',
        decimalDigits: 0,
      ).format(total.abs());
    }

    return Column(
      children: [
        if (items.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateHeader,
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                totalStr,
                style: AppTextStyles.roboto14w400.copyWith(
                  color: totalStr.startsWith('-') ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
        for (int i = 0; i < items.length; i++) ...[
          RecentTransactionItemWidget(transaction: items[i]),
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

  Widget _buildMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Menu',
              style: AppTextStyles.roboto16w400.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Icon(Icons.more_vert, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMenuItem(
              Icons.add_circle_outline, 
              'Catat', 
              const Color(0xFFE8F5E9), 
              const Color(0xFF4CAF50),
              onTap: () => Get.toNamed(Routes.addTransaction),
            ),
            _buildMenuItem(
              Icons.history, 
              'Riwayat', 
              const Color(0xFFE3F2FD), 
              const Color(0xFF2196F3),
              onTap: () => Get.toNamed(Routes.transactionList),
            ),
            _buildMenuItem(
              Icons.person_outline, 
              'Profil', 
              const Color(0xFFF3E5F5), 
              const Color(0xFF9C27B0),
              onTap: () {
                try {
                  Get.find<MainNavigationController>().changeTab(2);
                } catch (e) {
                  Get.snackbar('Info', 'Navigasi profil belum tersedia');
                }
              },
            ),
            _buildMenuItem(
              Icons.more_horiz, 
              'Lainnya', 
              const Color(0xFFF5F5F5), 
              const Color(0xFF9E9E9E),
              onTap: () => Get.snackbar('Info', 'Fitur belum tersedia'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            label,
            style: AppTextStyles.roboto14w400.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
