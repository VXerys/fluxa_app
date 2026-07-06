import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:fluxa_app/core/widgets/placeholder_page.dart';
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
          style: AppTextStyles.lora24w400.copyWith(fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(context, authController),
              const SizedBox(height: AppSpacing.s32),
              _buildSectionLabel('Aplikasi'),
              _buildCard([
                _buildCardItem(
                  icon: AppHugeIcons.upload_file,
                  title: 'Impor Data',
                  onTap: () => Get.to(
                    () => const PlaceholderPage(
                      title: 'Impor Data',
                      message:
                          'Fitur Impor Data sedang dalam proses pengembangan. Kami sedang menyiapkan pengalaman terbaik untuk Anda!',
                    ),
                  ),
                ),
                _buildCardItem(
                  icon: AppHugeIcons.date_range,
                  title: 'Periode Pencatatan',
                  onTap: () => Get.to(
                    () => const PlaceholderPage(
                      title: 'Periode Pencatatan',
                      message:
                          'Fitur Periode Pencatatan sedang dalam proses pengembangan. Kami sedang menyiapkan pengalaman terbaik untuk Anda!',
                    ),
                  ),
                ),
                _buildCardItem(
                  icon: AppHugeIcons.category,
                  title: 'Kategori',
                  onTap: () => Get.to(
                    () => const PlaceholderPage(
                      title: 'Kategori',
                      message:
                          'Fitur Kategori sedang dalam proses pengembangan. Kami sedang menyiapkan pengalaman terbaik untuk Anda!',
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: AppSpacing.s16),
              _buildSectionLabel('Preferensi'),
              _buildCard([
                _buildCardItem(
                  icon: AppHugeIcons.dark_mode,
                  title: 'Tema',
                  onTap: () => Get.to(
                    () => const PlaceholderPage(
                      title: 'Tema',
                      message:
                          'Fitur Tema sedang dalam proses pengembangan. Kami sedang menyiapkan pengalaman terbaik untuk Anda!',
                    ),
                  ),
                ),
                _buildCardItem(
                  icon: AppHugeIcons.credit_card,
                  title: 'Tampilan Kartu',
                  onTap: () => Get.toNamed(Routes.tampilanKartu),
                ),
                _buildCardItem(
                  icon: AppHugeIcons.menu,
                  title: 'Tampilan Menu',
                  onTap: () => Get.toNamed(Routes.tampilanMenu),
                ),
                _buildCardItem(
                  icon: AppHugeIcons.swap_vert,
                  title: 'Urutan Menu',
                  onTap: () => Get.toNamed(Routes.urutanMenu),
                ),
                _buildCardItem(
                  icon: AppHugeIcons.bar_chart,
                  title: 'Urutan Section Statistik',
                  onTap: () => Get.to(
                    () => const PlaceholderPage(
                      title: 'Urutan Statistik',
                      message:
                          'Fitur Urutan Section Statistik sedang dalam proses pengembangan. Kami sedang menyiapkan pengalaman terbaik untuk Anda!',
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: AppSpacing.s16),
              _buildSectionLabel('Data & Akun'),
              _buildCard([
                _buildCardItem(
                  icon: AppHugeIcons.delete_outline,
                  title: 'Reset Data Aplikasi',
                  iconColor: AppColors.error,
                  trailing: Obx(
                    () => controller.isResetting
                        ? const SizedBox(
                            width: AppSpacing.s16,
                            height: AppSpacing.s16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const AppIcon(
                            AppHugeIcons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                  ),
                  onTap: () => _showResetConfirmDialog(context),
                ),
                _buildCardItem(
                  icon: AppHugeIcons.logout,
                  title: 'Keluar',
                  iconColor: AppColors.error,
                  onTap: () =>
                      _showLogoutConfirmDialog(context, authController),
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
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(
    BuildContext context,
    AuthController authController,
  ) {
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
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const AppIcon(
                  AppHugeIcons.person,
                  size: 48,
                  color: AppColors.neutral,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showEditNameDialog(context, authController),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const AppIcon(
                      AppHugeIcons.edit,
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
              style: AppTextStyles.lora18w500.copyWith(
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
        style: AppTextStyles.lora14w400.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
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
    required AppIconData icon,
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
              child: AppIcon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              const AppIcon(
                AppHugeIcons.chevron_right,
                color: AppColors.textSecondary,
              ),
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

  void _showEditNameDialog(
    BuildContext context,
    AuthController authController,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _EditNameDialog(authController: authController);
      },
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final AuthController authController;

  const _EditNameDialog({required this.authController});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.authController.currentUser?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Ubah Nama',
        style: AppTextStyles.roboto18w500.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama Lengkap',
            style: AppTextStyles.roboto12w400.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: AppTextStyles.roboto16w400,
            decoration: InputDecoration(
              hintText: 'Masukkan nama Anda',
              hintStyle: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppColors.background,
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: AppTextStyles.roboto14w400.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Obx(() {
          final isSubmitting = widget.authController.isSubmitting;
          return ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () async {
                    final newName = _nameController.text.trim();
                    if (newName.isEmpty) {
                      Get.snackbar('Error', 'Nama tidak boleh kosong');
                      return;
                    }
                    final navigator = Navigator.of(context);
                    await widget.authController.updateProfile(
                      displayName: newName,
                    );
                    if (widget.authController.currentUser?.displayName ==
                        newName) {
                      navigator.pop();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: AppSpacing.s16,
                    height: AppSpacing.s16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Simpan',
                    style: AppTextStyles.roboto14w400.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          );
        }),
      ],
    );
  }
}
