import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';
import 'package:fluxa_app/core/constants/app_text_styles.dart';
import 'package:fluxa_app/core/routes/app_routes.dart';
import 'package:fluxa_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:fluxa_app/features/profile/presentation/controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: AppTextStyles.roboto18w500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(authController),
              const SizedBox(height: AppSpacing.s32),
              _buildSectionLabel('Aplikasi'),
              _buildCard([
                _buildCardItem(
                  icon: Icons.upload_file,
                  title: 'Impor Data',
                  onTap: () => Get.toNamed(Routes.imporData),
                ),
                _buildCardItem(
                  icon: Icons.date_range,
                  title: 'Periode Pencatatan',
                  onTap: () => Get.toNamed(Routes.periodePencatatan),
                ),
                _buildCardItem(
                  icon: Icons.category,
                  title: 'Kategori',
                  onTap: () => Get.toNamed(Routes.kategori),
                ),
                _buildCardItem(
                  icon: Icons.account_balance_wallet,
                  title: 'Pengaturan Dompet',
                  onTap: () => Get.toNamed(Routes.pengaturanDompet),
                ),
              ]),
              const SizedBox(height: AppSpacing.s16),
              _buildSectionLabel('Preferensi'),
              _buildCard([
                _buildCardItem(
                  icon: Icons.dark_mode,
                  title: 'Tema',
                  onTap: () => Get.toNamed(Routes.tema),
                ),
                _buildCardItem(
                  icon: Icons.credit_card,
                  title: 'Tampilan Kartu',
                  onTap: () => Get.toNamed(Routes.tampilanKartu),
                ),
                _buildCardItem(
                  icon: Icons.menu,
                  title: 'Tampilan Menu',
                  onTap: () => Get.toNamed(Routes.tampilanMenu),
                ),
                _buildCardItem(
                  icon: Icons.swap_vert,
                  title: 'Urutan Menu',
                  onTap: () => Get.toNamed(Routes.urutanMenu),
                ),
                _buildCardItem(
                  icon: Icons.bar_chart,
                  title: 'Urutan Section Statistik',
                  onTap: () => Get.toNamed(Routes.urutanStatistik),
                ),
              ]),
              const SizedBox(height: AppSpacing.s16),
              _buildSectionLabel('Data & Akun'),
              _buildCard([
                _buildCardItem(
                  icon: Icons.delete_outline,
                  title: 'Reset Data Aplikasi',
                  iconColor: AppColors.error,
                  trailing: Obx(
                    () => controller.isResetting
                        ? const SizedBox(
                            width: AppSpacing.s16,
                            height: AppSpacing.s16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ),
                  onTap: () => _showResetConfirmDialog(context),
                ),
                _buildCardItem(
                  icon: Icons.logout,
                  title: 'Keluar',
                  iconColor: AppColors.error,
                  onTap: () => _showLogoutConfirmDialog(context, authController),
                ),
              ]),
              const SizedBox(height: AppSpacing.s32),
              Center(
                child: Text(
                  'Fluxa © 2026',
                  style: AppTextStyles.roboto12w400.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(AuthController authController) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 48,
                  color: AppColors.neutral,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.toNamed(Routes.editProfile),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Obx(
            () => Text(
              authController.currentUser?.displayName ?? 'Pengguna Fluxa',
              style: AppTextStyles.roboto18w500.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.s8,
        bottom: AppSpacing.s8,
      ),
      child: Text(
        text,
        style: AppTextStyles.roboto14w400.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildCardItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color iconColor = AppColors.primary,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.roboto16w400.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Data Aplikasi?'),
          content: const Text(
            'Semua data aplikasi Anda akan dihapus dari cloud dan lokal.\n'
            'Akun login dan profil tetap aman.',
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

  void _showLogoutConfirmDialog(
    BuildContext context,
    AuthController authController,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                authController.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}
