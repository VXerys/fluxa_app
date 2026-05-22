import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../navigation/presentation/controllers/main_navigation_controller.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../controllers/home_controller.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/recent_transaction_item_widget.dart';
import 'package:intl/intl.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadSummary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('~ Hai!', style: AppTextStyles.lora24w400),
                        const SizedBox(height: AppSpacing.s16),
                        Obx(
                          () => BalanceCardWidget(summary: controller.summary),
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        _buildMenu(),
                        const SizedBox(height: AppSpacing.s24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Transaksi Terakhir',
                                style: AppTextStyles.roboto16w400.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () =>
                                  Get.toNamed(Routes.transactionList),
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
                        const SizedBox(height: AppSpacing.s32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(HomeController controller) {
    if (controller.isLoading && controller.summary == null) {
      return _buildRecentShimmer();
    }

    final summary = controller.summary;
    final List<HomeTransactionGroupEntity> recentGroups =
        summary?.recentTransactionGroups ?? const <HomeTransactionGroupEntity>[];

    if (summary == null || recentGroups.isEmpty) {
      return Text(
        'Belum ada transaksi',
        style: AppTextStyles.roboto14w400.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }
    final bool showMoreLink = summary.hasMoreRecentTransactions;

    // Indonesian Day and Month names
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in recentGroups) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${days[group.date.weekday - 1]}, ${group.date.day} ${months[group.date.month - 1]} ${group.date.year}',
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${group.netAmount < 0 ? '-' : '+'}${_currencyFormatter.format(group.netAmount.abs())}',
                style: AppTextStyles.roboto14w400.copyWith(
                  color: group.netAmount < 0
                      ? AppColors.error
                      : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          ...group.transactions.map((tx) {
            return RecentTransactionItemWidget(transaction: tx);
          }),
          const SizedBox(height: AppSpacing.s12),
        ],
        if (showMoreLink) ...[
          Center(
            child: TextButton(
              onPressed: () => Get.toNamed(Routes.transactionList),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Transaksi lainnya',
                    style: AppTextStyles.roboto14w400.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
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
                  Get.find<MainNavigationController>().changeTab(3);
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

  Widget _buildMenuItem(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
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
