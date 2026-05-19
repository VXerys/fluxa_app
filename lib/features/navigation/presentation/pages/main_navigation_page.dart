import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/placeholder_page.dart';
import '../controllers/main_navigation_controller.dart';

class MainNavigationPage extends GetView<MainNavigationController> {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex,
          children: const [
            PlaceholderPage(title: 'Home', message: 'Home pending'),
            PlaceholderPage(title: 'Transaksi', message: 'Transaksi pending'),
            PlaceholderPage(title: 'Profil', message: 'Profil pending'),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    const items = <_NavItemData>[
      _NavItemData(label: 'Home', icon: Icons.home_rounded, tabIndex: 0),
      _NavItemData(label: 'Statistik', icon: Icons.bar_chart_rounded),
      _NavItemData(
        label: 'Dompet',
        icon: Icons.account_balance_wallet_rounded,
        tabIndex: 1,
      ),
      _NavItemData(label: 'Profil', icon: Icons.person_rounded, tabIndex: 2),
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.s32),
          child: BottomAppBar(
            color: AppColors.surface,
            elevation: AppSpacing.s8,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              child: Obx(() {
                final activeIndex = controller.currentIndex;
                return Row(
                  children: items.map((item) {
                    final isActive =
                        item.tabIndex != null && item.tabIndex == activeIndex;
                    final color = isActive
                        ? AppColors.primary
                        : AppColors.neutral;

                    return Expanded(
                      child: _NavItem(
                        label: item.label,
                        icon: item.icon,
                        color: color,
                        onTap: () => _handleNavTap(context, item),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    final fabSize = AppSpacing.s48 + AppSpacing.s8;
    return CircularButton(
      color: AppColors.primary,
      icon: Icons.add,
      size: fabSize,
      onTap: () => Get.toNamed(Routes.addTransaction),
    );
  }

  void _handleNavTap(BuildContext context, _NavItemData item) {
    final tabIndex = item.tabIndex;
    if (tabIndex == null) {
      _showComingSoon(context);
      return;
    }

    controller.changeTab(tabIndex);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.textPrimary,
        content: Text(
          'Coming soon',
          style: AppTextStyles.roboto14w400.copyWith(color: AppColors.surface),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.s16),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: AppSpacing.s24),
            SizedBox(height: AppSpacing.s4),
            Text(
              label,
              style: AppTextStyles.roboto12w400.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final int? tabIndex;

  const _NavItemData({required this.label, required this.icon, this.tabIndex});
}

class CircularButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const CircularButton({
    super.key,
    required this.color,
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: color,
        elevation: AppSpacing.s8,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(icon, color: AppColors.surface, size: AppSpacing.s24),
          ),
        ),
      ),
    );
  }
}
