import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../controllers/main_navigation_controller.dart';

// ... import tetap sama ...

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
              ProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface, // Warna dasar yang kamu inginkan
        surfaceTintColor: Colors
            .transparent, // <-- TAMBAHKAN INI UNTUK MENGHILANGKAN ABU-ABU MATERIAL 3
        shadowColor: Colors
            .black26, // <-- (Opsional) Tambahkan ini agar bayangan elevation lebih natural, bukan abu-abu kusam
        elevation: 20,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: AppHugeIcons.home_rounded,
                activeIcon: AppHugeIcons.solid_home,
                label: 'Home',
                index: 0,
                controller: controller,
              ),
              _NavItem(
                icon: AppHugeIcons.analytics_rounded,
                activeIcon: AppHugeIcons.solid_analytics,
                label: 'Statistics',
                index: 1,
                controller: controller,
              ),
              _NavItem(
                icon: AppHugeIcons.person_rounded,
                activeIcon: AppHugeIcons.solid_user,
                label: 'Profile',
                index: 2,
                controller: controller,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... class _NavItem tetap sama ...

class _NavItem extends StatelessWidget {
  final AppIconData icon;
  final AppIconData? activeIcon;
  final String label;
  final int index;
  final MainNavigationController controller;
  final bool disabled;

  const _NavItem({
    required this.icon,
    this.activeIcon,
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

        final displayIcon = (isActive && activeIcon != null)
            ? activeIcon!
            : icon;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(displayIcon, color: color, size: 32),
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
