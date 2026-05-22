import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';
import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';
import 'package:fluxa_app/core/constants/app_text_styles.dart';
import 'package:fluxa_app/features/profile/presentation/controllers/profile_controller.dart';

class TampilanKartuPage extends GetView<ProfileController> {
  const TampilanKartuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilih Tema Kartu', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.s16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.s16,
          mainAxisSpacing: AppSpacing.s16,
          childAspectRatio: 1.5,
        ),
        itemCount: ProfileController.cardThemes.length,
        itemBuilder: (context, index) {
          final theme = ProfileController.cardThemes[index];
          return Obx(() {
            final isSelected = controller.selectedThemeIndex.value == index;
            final colors = theme['colors'] as List<Color>;
            return GestureDetector(
              onTap: () {
                controller.selectTheme(index);
                Get.snackbar(
                  'Tema Kartu',
                  'Tema ${theme['name']} berhasil diterapkan!',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(16),
                );
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors[0].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        theme['name'] as String,
                        style: AppTextStyles.roboto16w400.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: AppIcon(
                          AppHugeIcons.check,
                          color: colors[0],
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}




