import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../controllers/main_navigation_controller.dart';

class MainNavigationPage extends GetView<MainNavigationController> {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.stackIndex,
          children: const [
            HomePage(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 88,
        child: Stack(
          children: [
            Positioned(
              left: 16,
              right: 88,
              bottom: 16,
              child: _buildPillNav(),
            ),
            Positioned(right: 16, bottom: 16, child: _buildFAB()),
          ],
        ),
      ),
    );
  }

  Widget _buildPillNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            outlinedIcon: Icons.home_outlined,
            index: 0,
            controller: controller,
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            outlinedIcon: Icons.bar_chart,
            index: 1,
            controller: controller,
            disabled: true,
          ),
          _NavItem(
            icon: Icons.account_balance_wallet_rounded,
            outlinedIcon: Icons.account_balance_wallet_outlined,
            index: 2,
            controller: controller,
            disabled: true,
          ),
          _NavItem(
            icon: Icons.person_rounded,
            outlinedIcon: Icons.person_outline_rounded,
            index: 3,
            controller: controller,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.addTransaction),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final int index;
  final MainNavigationController controller;
  final bool disabled;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.index,
    required this.controller,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: disabled ? null : () => controller.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                final isActive = controller.currentIndex == index;
                final color = disabled
                    ? const Color(0xFFE0E0E0)
                    : isActive
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFFBDBDBD);

                return Icon(
                  isActive ? icon : outlinedIcon,
                  color: color,
                  size: 26,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
