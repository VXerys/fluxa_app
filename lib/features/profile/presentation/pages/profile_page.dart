import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';
import 'package:fluxa_app/core/constants/app_text_styles.dart';
import 'package:fluxa_app/features/profile/presentation/controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(),
              SizedBox(height: AppSpacing.s32),
              _buildSectionLabel('Aplikasi'),
              _buildAppSettingsCard(),
              SizedBox(height: AppSpacing.s16),
              _buildSectionLabel('Data'),
              _buildDataSettingsCard(context),
              SizedBox(height: AppSpacing.s32),
              Center(
                child: Text(
                  'Fluxa © 2026',
                  style: AppTextStyles.roboto12w400.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: AppSpacing.s48,
            backgroundColor: AppColors.neutral,
            child: Icon(
              Icons.person,
              size: AppSpacing.s48,
              color: AppColors.surface,
            ),
          ),
          SizedBox(height: AppSpacing.s12),
          const Text('Pengguna Fluxa', style: AppTextStyles.roboto18w500),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.s16),
      child: Text(
        text,
        style: AppTextStyles.roboto12w400.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAppSettingsCard() {
    return _buildSettingsCard(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline, color: AppColors.primary),
          title: const Text('Tentang Fluxa'),
          subtitle: const Text('Aplikasi pencatatan keuangan pribadi'),
        ),
        Divider(
          height: AppSpacing.s4,
          thickness: AppSpacing.s4 / AppSpacing.s4,
        ),
        ListTile(
          leading: const Icon(Icons.tag, color: AppColors.primary),
          title: const Text('Versi'),
          trailing: Obx(
            () => Text(
              controller.appVersion,
              style: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSettingsCard(BuildContext context) {
    return _buildSettingsCard(
      children: [
        ListTile(
          leading: const Icon(Icons.delete_outline, color: AppColors.error),
          title: Text(
            'Reset Data Lokal',
            style: AppTextStyles.roboto14w400.copyWith(color: AppColors.error),
          ),
          subtitle: const Text('Hapus cache dan data lokal di perangkat ini'),
          trailing: Obx(
            () => controller.isResetting
                ? SizedBox(
                    width: AppSpacing.s16,
                    height: AppSpacing.s16,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSpacing.s8 / AppSpacing.s4,
                    ),
                  )
                : const Icon(Icons.chevron_right, color: AppColors.neutral),
          ),
          onTap: () => _showResetConfirmDialog(context),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.s12),
        ),
        child: Column(children: children),
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Data Lokal?'),
          content: const Text(
            'Cache dan data lokal di perangkat ini akan dihapus.\n'
            'Transaksi di cloud tidak dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                controller.resetData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
