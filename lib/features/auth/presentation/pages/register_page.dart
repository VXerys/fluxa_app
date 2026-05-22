import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s16),
              Text('Fluxa', style: AppTextStyles.lora36w400.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Daftar akun baru untuk mulai mencatat.',
                style: AppTextStyles.roboto14w400.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.12)),
                  ),
                  child: _RegisterForm(controller: controller),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({required this.controller});

  final AuthController controller;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.clearError();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daftar', style: AppTextStyles.roboto18w600),
        const SizedBox(height: AppSpacing.s16),
        Obx(() {
          final String error = widget.controller.errorMessage;
          if (error.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s16),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(error, style: AppTextStyles.roboto14w400.copyWith(color: AppColors.error)),
                ),
              ],
            ),
          );
        }),
        TextField(
          controller: _displayNameController,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration('Nama Lengkap', Icons.person_outline),
        ),
        const SizedBox(height: AppSpacing.s14),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration('Email', Icons.email_outlined),
        ),
        const SizedBox(height: AppSpacing.s14),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration(
            'Password',
            Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: AppIcon(
                _obscurePassword ? AppHugeIcons.visibility : AppHugeIcons.visibility_off,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: Obx(() {
            final bool isSubmitting = widget.controller.isSubmitting;
            return ElevatedButton(
              onPressed: isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                      ),
                    )
                  : Text('Daftar', style: AppTextStyles.roboto16w600.copyWith(color: AppColors.surface)),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.s8),
        Center(
          child: TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Sudah punya akun? Masuk',
              style: AppTextStyles.roboto14w400.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    widget.controller.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      displayName: _displayNameController.text,
    );
  }

  InputDecoration _inputDecoration(String label, IconData prefixIcon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.roboto14w400.copyWith(color: AppColors.textSecondary),
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
      ),
    );
  }
}
