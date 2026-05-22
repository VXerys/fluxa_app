import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';

import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';
import 'package:fluxa_app/core/constants/app_text_styles.dart';
import 'package:fluxa_app/features/auth/presentation/controllers/auth_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = authController.currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    authController.updateProfile(displayName: _nameController.text);
    if (!authController.isSubmitting) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: AppTextStyles.roboto18w500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppHugeIcons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const AppIcon(
                        AppHugeIcons.person,
                        size: 36,
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              Text(
                'Nama Lengkap',
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.roboto16w400,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  labelStyle: AppTextStyles.roboto14w400,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.s12),
                    borderSide: const BorderSide(color: AppColors.primaryLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.s12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const Spacer(),
              Obx(() {
                final isSubmitting = authController.isSubmitting;
                return ElevatedButton(
                  onPressed: isSubmitting ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.s12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: AppSpacing.s16,
                          height: AppSpacing.s16,
                          child: CircularProgressIndicator(
                            strokeWidth: AppSpacing.s4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.surface,
                            ),
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: AppTextStyles.roboto16w400.copyWith(
                            color: AppColors.surface,
                          ),
                        ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}




