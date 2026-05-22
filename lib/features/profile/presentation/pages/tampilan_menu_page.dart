import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';
import 'package:fluxa_app/core/constants/app_text_styles.dart';
import 'package:fluxa_app/core/routes/app_routes.dart';
import 'package:fluxa_app/features/profile/presentation/controllers/profile_controller.dart';

class TampilanMenuPage extends GetView<ProfileController> {
  const TampilanMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tampilan Menu',
          style: AppTextStyles.roboto18w600.copyWith(
            color: AppColors.textPrimary,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(Routes.urutanMenu),
            child: Text(
              'Urutan Menu',
              style: AppTextStyles.roboto14w500.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s8,
          AppSpacing.s16,
          AppSpacing.s24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pratinjau',
              style: AppTextStyles.roboto18w600.copyWith(
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Obx(() {
              final List<HomeMenuDefinition> menus = controller.orderedHomeMenus;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List<Widget>.generate(menus.length, (int index) {
                    final HomeMenuDefinition menu = menus[index];
                    return Expanded(
                      child: _PreviewMenuItem(
                        icon: menu.icon,
                        label: menu.label,
                        iconColor: controller.menuAccentColorAt(index),
                        bgColor: controller.menuBgColorAt(index),
                      ),
                    );
                  }),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Warna Campuran',
              style: AppTextStyles.roboto18w600.copyWith(
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Obx(() {
              return Column(
                children: List<Widget>.generate(
                  ProfileController.menuColorPalettes.length,
                  (int index) {
                    final MenuColorPalette palette =
                        ProfileController.menuColorPalettes[index];
                    final bool isSelected =
                        controller.selectedMenuPaletteIndex.value == index;
                    return _PaletteCard(
                      palette: palette,
                      isSelected: isSelected,
                      onTap: () => controller.selectMenuPalette(index),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Urutkan menu dengan drag & drop di halaman Urutan Menu.',
              style: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;

  const _PreviewMenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final MenuColorPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.08),
              width: isSelected ? 2.2 : 1,
            ),
          ),
          child: Row(
            children: [
              ...palette.colors.map((Color color) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s8),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  palette.name,
                  style: AppTextStyles.roboto18w600.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
