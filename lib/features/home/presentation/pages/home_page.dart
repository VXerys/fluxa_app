import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
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
        bottom: false,
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
                        Obx(() {
                          final authController = Get.find<AuthController>();
                          final name =
                              authController.currentUser?.displayName ??
                              'Pengguna Fluxa';
                          return Text(
                            '~ Hai, $name!',
                            style: AppTextStyles.lora24w400,
                          );
                        }),
                        const SizedBox(height: AppSpacing.s16),
                        Obx(() {
                          if (controller.isLoading && controller.summary == null) {
                            return _buildBalanceCardShimmer();
                          }
                          return BalanceCardWidget(summary: controller.summary);
                        }),
                        const SizedBox(height: AppSpacing.s8),
                        _buildMenu(),
                        const SizedBox(height: AppSpacing.s16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Transaksi Terakhir',
                                style: AppTextStyles.lora16w400.copyWith(
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
                                style: AppTextStyles.lora12w400.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Obx(() => _buildRecentTransactions(controller)),
                        const SizedBox(height: 120),
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
        summary?.recentTransactionGroups ??
        const <HomeTransactionGroupEntity>[];

    if (summary == null || recentGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s24,
            horizontal: AppSpacing.s16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Belum ada transaksi',
                style: AppTextStyles.lora18w600.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Text(
                  'Ayo mulai catat pengeluaran dan pemasukanmu agar keuangan lebih rapi!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.roboto14w400.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              OutlinedButton(
                onPressed: () => Get.toNamed(Routes.addTransaction),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                  foregroundColor: AppColors.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: AppColors.primary, size: 18),
                    const SizedBox(width: AppSpacing.s6),
                    Text(
                      'Tambah Transaksi',
                      style: AppTextStyles.roboto16w600.copyWith(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],
          ),
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
          const SizedBox(height: AppSpacing.s12),
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
                  const AppIcon(
                    AppHugeIcons.chevron_right,
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
            baseColor: AppColors.neutral.withValues(alpha: 0.1),
            highlightColor: AppColors.surface,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 70,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCardShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral.withValues(alpha: 0.15),
      highlightColor: AppColors.surface,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Container(
              width: 200,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    final ProfileController profileController = Get.find<ProfileController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Menu',
              style: AppTextStyles.lora16w400.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            PopupMenuButton<String>(
              color: AppColors.surface,
              child: const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: AppIcon(
                  AppHugeIcons.more_vert,
                  color: AppColors.textSecondary,
                ),
              ),
              onSelected: (String value) {
                if (value == 'tampilan_menu') {
                  Get.toNamed(Routes.tampilanMenu);
                  return;
                }
                if (value == 'urutan_menu') {
                  Get.toNamed(Routes.urutanMenu);
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'tampilan_menu',
                    child: Row(
                      children: [
                        const AppIcon(
                          AppHugeIcons.palette_outlined,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          'Tampilan Menu',
                          style: AppTextStyles.roboto14w400.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'urutan_menu',
                    child: Row(
                      children: [
                        const AppIcon(
                          AppHugeIcons.drag_indicator_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          'Urutan Menu',
                          style: AppTextStyles.roboto14w400.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        Obx(() {
          final List<HomeMenuDefinition> menus =
              profileController.orderedHomeMenus;
          return Row(
            children: List<Widget>.generate(menus.length, (int index) {
              final HomeMenuDefinition menu = menus[index];
              return Expanded(
                child: _buildMenuItem(
                  menu.icon,
                  menu.label,
                  profileController.menuBgColorAt(index),
                  profileController.menuAccentColorAt(index),
                  onTap: () => _onMenuTap(menu.actionKey),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  void _onMenuTap(String actionKey) {
    switch (actionKey) {
      case 'transaction_list':
        Get.toNamed(Routes.transactionList);
        break;
      case 'voice_placeholder':
        Get.toNamed(Routes.voiceTransaction);
        break;
      default:
        break;
    }
  }

  Widget _buildMenuItem(
    AppIconData icon,
    String label,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppIcon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.roboto12w400.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
