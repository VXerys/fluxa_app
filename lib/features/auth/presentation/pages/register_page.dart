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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s24),
              const Text('Fluxa', style: AppTextStyles.lora36w400),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Catat keuanganmu dengan mudah',
                style: AppTextStyles.roboto14w400.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              _RegisterForm(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final AuthController controller;

  const _RegisterForm({required this.controller});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
      children: [
        TextFormField(
          controller: _displayNameController,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration('Nama Lengkap'),
        ),
        const SizedBox(height: AppSpacing.s16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration('Email'),
        ),
        const SizedBox(height: AppSpacing.s16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration(
            'Password',
            suffixIcon: IconButton(
              icon: AppIcon(
                _obscurePassword ? AppHugeIcons.visibility : AppHugeIcons.visibility_off,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        SizedBox(
          width: double.infinity,
          child: Obx(() {
            final isSubmitting = widget.controller.isSubmitting;
            return ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      widget.controller.signUp(
                        email: _emailController.text,
                        password: _passwordController.text,
                        displayName: _displayNameController.text,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
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
                      'Daftar',
                      style: AppTextStyles.roboto16w400.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.s16),
        Center(
          child: TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Sudah punya akun? Masuk',
              style: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
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
      suffixIcon: suffixIcon,
    );
  }
}




