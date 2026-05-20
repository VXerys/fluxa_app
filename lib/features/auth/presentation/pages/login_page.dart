import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

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
              _LoginForm(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final AuthController controller;

  const _LoginForm({required this.controller});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                      widget.controller.signIn(
                        email: _emailController.text,
                        password: _passwordController.text,
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
                      'Masuk',
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
            onPressed: () => Get.toNamed(Routes.register),
            child: Text(
              'Belum punya akun? Daftar',
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
        borderSide: const BorderSide(color: AppColors.primaryVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.s12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      suffixIcon: suffixIcon,
    );
  }
}
