import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/placeholder_page.dart';
import '../controllers/auth_controller.dart';

class AuthPage extends StatefulWidget {
  final int initialTab;

  const AuthPage({
    super.key,
    this.initialTab = 0, // 0 = Login, 1 = Register
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late int _tabIndex;
  final AuthController controller = Get.find<AuthController>();

  // Login Controllers
  final TextEditingController _loginEmailController = TextEditingController(text: 'sehanfrs9@gmail.com');
  final TextEditingController _loginPasswordController = TextEditingController(text: 'Sehan123');

  // Register Controllers
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;

  String? _localError;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearError();
    });
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    if (_localError != null) {
      setState(() {
        _localError = null;
      });
    }
    controller.clearError();
  }

  void _submitLogin() {
    _clearErrors();
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _localError = 'Email tidak valid');
      return;
    }
    if (password.length < 6) {
      setState(() => _localError = 'Password minimal 6 karakter');
      return;
    }

    controller.signIn(email: email, password: password);
  }

  void _submitRegister() {
    _clearErrors();
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;
    final confirmPassword = _registerConfirmPasswordController.text;

    if (name.isEmpty) {
      setState(() => _localError = 'Nama Lengkap harus diisi');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _localError = 'Email tidak valid');
      return;
    }
    if (password.length < 6) {
      setState(() => _localError = 'Password minimal 6 karakter');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _localError = 'Password dan konfirmasi password tidak cocok');
      return;
    }

    controller.signUp(
      email: email,
      password: password,
      displayName: name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s24,
                      vertical: AppSpacing.s32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppSpacing.s24),
                        _buildTabSwitcher(),
                        const SizedBox(height: AppSpacing.s24),
                        if (_tabIndex == 0)
                          _buildLoginForm()
                        else
                          _buildRegisterForm(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_tabIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, Selamat Datang!',
            style: AppTextStyles.lora24w400.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Masuk ke akun Anda',
            style: AppTextStyles.roboto14w400.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buat Akun Baru',
            style: AppTextStyles.lora24w400.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          RichText(
            text: TextSpan(
              style: AppTextStyles.roboto14w400.copyWith(color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'Sudah punya akun? '),
                TextSpan(
                  text: 'Masuk',
                  style: AppTextStyles.roboto14w500.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _tabIndex = 0;
                        _clearErrors();
                      });
                    },
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_tabIndex != 0) {
                  setState(() {
                    _tabIndex = 0;
                    _clearErrors();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: _tabIndex == 0 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Login',
                  style: AppTextStyles.roboto16w600.copyWith(
                    color: _tabIndex == 0 ? AppColors.surface : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_tabIndex != 1) {
                  setState(() {
                    _tabIndex = 1;
                    _clearErrors();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: _tabIndex == 1 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Register',
                  style: AppTextStyles.roboto16w600.copyWith(
                    color: _tabIndex == 1 ? AppColors.surface : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildErrorBanner(),
        Text(
          'Email',
          style: AppTextStyles.roboto14w500.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration(
            prefixIcon: Icons.email_outlined,
            hintText: 'Masukkan email Anda',
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          'Password',
          style: AppTextStyles.roboto14w500.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitLogin(),
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration(
            prefixIcon: Icons.lock_outline,
            hintText: 'Masukkan password Anda',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
              icon: AppIcon(
                _obscureLoginPassword ? AppHugeIcons.visibility : AppHugeIcons.visibility_off,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: AppSpacing.s10),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Get.to(() => const PlaceholderPage(
                  title: 'Lupa Password',
                  message: 'Fitur ini sedang dikembangkan',
                )),
            child: Text(
              'Lupa Password?',
              style: AppTextStyles.roboto14w500.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        _buildCTAButton(
          label: 'Masuk',
          onPressed: _submitLogin,
        ),
        const SizedBox(height: AppSpacing.s24),
        _buildSocialDivider(),
        const SizedBox(height: AppSpacing.s16),
        _buildSocialButtons(),
        const SizedBox(height: AppSpacing.s24),
        Center(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.roboto14w400.copyWith(color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'Belum punya akun? '),
                TextSpan(
                  text: 'Daftar',
                  style: AppTextStyles.roboto14w500.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _tabIndex = 1;
                        _clearErrors();
                      });
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildErrorBanner(),
        Text(
          'Nama Lengkap',
          style: AppTextStyles.roboto14w500.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: _registerNameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration(
            prefixIcon: Icons.person_outline,
            hintText: 'Masukkan nama lengkap Anda',
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          'Email',
          style: AppTextStyles.roboto14w500.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration(
            prefixIcon: Icons.email_outlined,
            hintText: 'Masukkan email Anda',
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          'Password',
          style: AppTextStyles.roboto14w500.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: _registerPasswordController,
          obscureText: _obscureRegisterPassword,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration(
            prefixIcon: Icons.lock_outline,
            hintText: 'Masukkan password Anda',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureRegisterPassword = !_obscureRegisterPassword),
              icon: AppIcon(
                _obscureRegisterPassword ? AppHugeIcons.visibility : AppHugeIcons.visibility_off,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          'Konfirmasi Password',
          style: AppTextStyles.roboto14w500.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: _registerConfirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitRegister(),
          style: AppTextStyles.roboto16w400,
          decoration: _inputDecoration(
            prefixIcon: Icons.lock_outline,
            hintText: 'Masukkan kembali password Anda',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              icon: AppIcon(
                _obscureConfirmPassword ? AppHugeIcons.visibility : AppHugeIcons.visibility_off,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: AppSpacing.s24),
        _buildCTAButton(
          label: 'Daftar',
          onPressed: _submitRegister,
        ),
        const SizedBox(height: AppSpacing.s24),
        _buildSocialDivider(),
        const SizedBox(height: AppSpacing.s16),
        _buildSocialButtons(),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Obx(() {
      final String controllerError = controller.errorMessage;
      final String displayError = _localError ?? controllerError;
      if (displayError.isEmpty) return const SizedBox.shrink();
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
              child: Text(
                displayError,
                style: AppTextStyles.roboto14w400.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    });
  }

  InputDecoration _inputDecoration({
    required IconData prefixIcon,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: AppTextStyles.roboto14w400.copyWith(color: AppColors.textSecondary),
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

  Widget _buildCTAButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Obx(() {
        final bool isSubmitting = controller.isSubmitting;
        return ElevatedButton(
          onPressed: isSubmitting ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            elevation: 0,
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
              : Text(
                  label,
                  style: AppTextStyles.roboto16w600.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildSocialDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          child: Text(
            'atau',
            style: AppTextStyles.roboto12w400.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return SizedBox(
      width: double.infinity,
      child: _buildSocialButton(
        logo: _googleLogo(),
        label: 'Masuk dengan Google',
        onTap: () => Get.to(() => const PlaceholderPage(
              title: 'Login Google',
              message: 'Fitur Google Login sedang dikembangkan',
            )),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget logo,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo,
            const SizedBox(width: AppSpacing.s8),
            Text(
              label,
              style: AppTextStyles.roboto16w600.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleLogo() {
    return const AppIcon(
      'assets/icons/google.svg',
      size: 18,
    );
  }
}
