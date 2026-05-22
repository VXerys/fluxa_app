import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/category_color_parser.dart';
import '../../domain/entities/wallet_entity.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/add_wallet_bottom_sheet.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

class WalletPage extends GetView<WalletController> {
  const WalletPage({super.key});

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom + 80;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,

        title: Text(
          'Dompet Saya',
          style: AppTextStyles.lora24w400.copyWith(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to<void>(
                () => const _AddWalletFlowPage(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 260),
              );
            },
            icon: const Icon(Icons.add, color: AppColors.textPrimary, size: 28),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.loadWallets,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                  child: _buildSummaryCard(),
                ),
                const SizedBox(height: AppSpacing.s24),
                _buildSectionTitle('Tunai'),
                const SizedBox(height: AppSpacing.s8),
                _buildCashSection(),
                const SizedBox(height: AppSpacing.s24),
                _buildSectionTitle('Akun Bank'),
                const SizedBox(height: AppSpacing.s8),
                _buildBankSection(),
                const SizedBox(height: AppSpacing.s24),
                _buildSectionTitle('E-Wallet'),
                const SizedBox(height: AppSpacing.s8),
                _buildEwalletSection(),
                SizedBox(
                  height: bottomPadding,
                ), // Spacing to avoid being hidden behind bottom navigation bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final profileController = Get.find<ProfileController>();
    return Obx(() {
      if (controller.isLoading && controller.wallets.isEmpty) {
        return _buildSummaryShimmer();
      }

      final selectedThemeIndex = profileController.selectedThemeIndex.value;
      final theme = ProfileController.cardThemes[selectedThemeIndex];
      final colors = theme['colors'] as List<Color>;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dapat Dibelanjakan (IDR)',
                  style: AppTextStyles.roboto14w400.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                _currencyFormatter.format(controller.totalBalance),
                style: AppTextStyles.lora36w400.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: AppSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.s24),
                  ),
                  child: Text(
                    '↓ -10.0%',
                    style: AppTextStyles.roboto12w400.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '(${_currencyFormatter.format(50000)}) 30 hari terakhir',
                  style: AppTextStyles.roboto12w400.copyWith(
                    color: AppColors.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSubInfoBox(
                        title: 'Saldo Bersih',
                        value: _currencyFormatter.format(
                          controller.totalBalance,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: _buildSubInfoBox(
                        title: 'Hutang Aktif',
                        value: _currencyFormatter.format(0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSubInfoBox(
                        title: 'Tabungan Aktif',
                        value: _currencyFormatter.format(0),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: _buildSubInfoBox(
                        title: 'Pembayaran Mendatang',
                        value: _currencyFormatter.format(0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubInfoBox({required String title, required String value}) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.surface.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: AppTextStyles.roboto12w400.copyWith(
                color: AppColors.surface.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.roboto14w500.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashSection() {
    return Obx(() {
      if (controller.isLoading && controller.wallets.isEmpty) {
        return _buildWalletListShimmer();
      }
      if (controller.cashWallets.isEmpty) {
        return _buildEmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Belum ada dompet Tunai',
          subtitle: 'Ketuk + di pojok kanan atas untuk menambahkan',
        );
      }
      return _buildWalletList(controller.cashWallets);
    });
  }

  Widget _buildBankSection() {
    return Obx(() {
      if (controller.isLoading && controller.wallets.isEmpty) {
        return _buildWalletListShimmer();
      }
      if (controller.bankWallets.isEmpty) {
        return _buildEmptyState(
          icon: Icons.account_balance_outlined,
          title: 'Belum ada dompet Akun Bank',
          subtitle: 'Ketuk + di pojok kanan atas untuk menambahkan',
        );
      }
      return _buildWalletList(controller.bankWallets);
    });
  }

  Widget _buildEwalletSection() {
    return Obx(() {
      if (controller.isLoading && controller.wallets.isEmpty) {
        return _buildWalletListShimmer();
      }
      if (controller.ewalletWallets.isEmpty) {
        return _buildEmptyState(
          icon: Icons.credit_card_outlined,
          title: 'Belum ada dompet E-Wallet',
          subtitle: 'Ketuk + di pojok kanan atas untuk menambahkan',
        );
      }
      return _buildWalletList(controller.ewalletWallets);
    });
  }

  Widget _buildWalletList(List<WalletEntity> wallets) {
    return ListView.separated(
      itemCount: wallets.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (_, index) {
        final wallet = wallets[index];
        return _buildWalletItem(wallet);
      },
    );
  }

  IconData _walletIconByType(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance_outlined;
      case 'ewallet':
        return Icons.credit_card_outlined;
      case 'cash':
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Widget _buildWalletItem(WalletEntity wallet) {
    final Color walletColor = CategoryColorParser.parse(
      wallet.color,
      fallback: AppColors.primary,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.s16),
        onTap: () {
          Get.toNamed(Routes.walletDetail);
        },
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.s16),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.s48,
                height: AppSpacing.s48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: walletColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  _walletIconByType(wallet.type),
                  color: walletColor,
                  size: AppSpacing.s24,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.roboto16w600.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      '${wallet.type.toUpperCase()} • ${wallet.currency}',
                      style: AppTextStyles.roboto12w400.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Saldo Saat Ini',
                    style: AppTextStyles.roboto12w400.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    _currencyFormatter.format(wallet.balance),
                    style: AppTextStyles.roboto16w600.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Text(title, style: AppTextStyles.roboto16w600),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.s16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.s48,
            height: AppSpacing.s48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neutral.withValues(alpha: 0.08),
            ),
            child: Icon(icon, color: AppColors.neutral, size: AppSpacing.s24),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.roboto14w500.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  subtitle,
                  style: AppTextStyles.roboto12w400.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.background,
      highlightColor: AppColors.surface,
      child: Container(
        height: AppSpacing.s48 * 4,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.s16),
        ),
      ),
    );
  }

  Widget _buildWalletListShimmer() {
    return ListView.separated(
      itemCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: AppColors.background,
          highlightColor: AppColors.surface,
          child: Container(
            height: AppSpacing.s48 * 2,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.s16),
            ),
          ),
        );
      },
    );
  }
}

class _AddWalletFlowPage extends StatelessWidget {
  const _AddWalletFlowPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(child: AddWalletBottomSheet()),
    );
  }
}
