import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../controllers/main_navigation_controller.dart';

class MainNavigationPage extends GetView<MainNavigationController> {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => IndexedStack(
            index: controller.currentIndex,
            children: const [
              HomePage(),
              StatisticsPage(),
              WalletPage(),
              ProfilePage(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.addTransaction),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 20,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                outlinedIcon: Icons.home_outlined,
                label: 'Home',
                index: 0,
                controller: controller,
              ),
              _NavItem(
                icon: Icons.analytics_rounded,
                outlinedIcon: Icons.bar_chart_outlined,
                label: 'Statistics',
                index: 1,
                controller: controller,
              ),
              const SizedBox(width: 48), // Space for FAB
              _NavItem(
                icon: Icons.account_balance_wallet_rounded,
                outlinedIcon: Icons.account_balance_wallet_outlined,
                label: 'Wallet',
                index: 2,
                controller: controller,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                outlinedIcon: Icons.person_outline_rounded,
                label: 'Profile',
                index: 3,
                controller: controller,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final int index;
  final MainNavigationController controller;
  final bool disabled;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.index,
    required this.controller,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: Obx(() {
        final isActive = controller.currentIndex == index;
        final color = disabled
            ? AppColors.neutral
            : isActive
            ? AppColors.primary
            : AppColors.textSecondary;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? icon : outlinedIcon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.roboto12w400.copyWith(color: color),
            ),
          ],
        );
      }),
    );
  }
}
