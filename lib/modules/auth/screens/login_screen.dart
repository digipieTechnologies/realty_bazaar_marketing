// File: lib/modules/auth/screens/login_screen.dart
// Purpose: Interactive high-fidelity Auth portal with inline state transitions, phone validation, and password strength checks.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/app_assets.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/app_utils.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../util/common_ext.dart';
import '../../../widgets/buttons/rounded_button.dart';
import '../../../widgets/inputs/app_textfield.dart';
import '../../../widgets/toast/app_toast.dart';
import '../../../widgets/brand/app_logo.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/user_enums.dart';
import '../../../models/otp_type.dart';
import '../widgets/auth_footer_link_widget.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/password_field_widget.dart';

enum AuthMode { login, forgotPassword }

class LoginScreen extends StatefulWidget {
  final AuthMode initialMode;
  const LoginScreen({super.key, this.initialMode = AuthMode.login});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus nodes
  final _passwordFocusNode = FocusNode();

  late AuthMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _currentMode = mode;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  Future<void> _handleAuthSubmit() async {
    AppUtils.dismissKeyboard(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();

    if (_currentMode == AuthMode.login) {
      final success = await authProvider.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (success && mounted) {
        if (authProvider.userProfile?.isEmailVerified == false) {
          final targetEmail = _emailController.text.trim();
          await authProvider.resendEmailOtp(
            email: targetEmail,
            userId: authProvider.userProfile?.id,
            otpType: AppOtpType.emailVerify,
          );
          if (!mounted) return;
          AppToast.showError(
            'Email Verification Required',
            'We sent a 6-digit verification code to your email.',
          );
          context.go(
            AppRoutes.verifyOtp,
            extra: {
              'email': targetEmail,
              'userId': authProvider.userProfile?.id,
              'otpType': AppOtpType.emailVerify,
            },
          );
        } else {
          AppToast.showSuccess(
            context.tr('login_successful'),
            context.tr('welcome_back_generic'),
          );
          context.go(AppRoutes.home);
        }
      } else if (mounted) {
        AppToast.showError(
          context.tr('auth_error'),
          authProvider.errorMessage ?? context.tr('error_generic'),
        );
      }
    } else {
      final email = _emailController.text.trim();
      final success = await authProvider.requestForgotPasswordOtp(
        email,
        expectedRole: UserRole.marketing,
      );
      if (success && mounted) {
        AppToast.showSuccess(
          'Verification Code Sent',
          'Please check your email for the 6-digit password reset code.',
        );
        context.go(
          AppRoutes.verifyOtp,
          extra: {
            'email': email,
            'otpType': AppOtpType.forgotPassword,
          },
        );
      } else if (mounted) {
        AppToast.showError(
          context.tr('auth_error'),
          authProvider.errorMessage ?? context.tr('error_generic'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopUI;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Stack(
        children: [
          // Background soft glowing shapes for mobile view (low contrast theme-matching design)
          if (!isDesktop) ...[
            Positioned(
              top: -120,
              right: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.03),
                ),
              ),
            ),
          ],

          Row(
            children: [
              // Left Sidebar (Skyscraper view, visible only on larger viewports)
              if (isDesktop) Expanded(child: _leftSidebar()),

              // Right Form Column
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Wrap form in a premium card structure on mobile viewports
                            isDesktop
                                ? _formContent()
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 24.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24.0),
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 20.0,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: _formContent(),
                                  ),
                            const SizedBox(height: 32.0),
                            _copyrightFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LEFT SIDEBAR COMPONENT ---
  Widget _leftSidebar() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.building),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDark.withOpacity(0.85),
              AppColors.primary.withOpacity(0.70),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: const EdgeInsets.all(48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // White background transparent logo badge
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: const AppLogo(size: 38.0),
            ),
            const Spacer(),

            // Hero Title & Description
            Text(
              context.tr('empowering_leaders'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              context.tr('join_network'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 15.0,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 40.0),

            // Bottom Glassmorphic feature Cards
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _glassmorphicCard(
                      icon: Icons.analytics_outlined,
                      title: context.tr('adv_reporting'),
                      desc:
                          context.tr('adv_reporting_desc'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _glassmorphicCard(
                      icon: Icons.apartment_outlined,
                      title: context.tr('asset_control'),
                      desc:
                          context.tr('asset_control_desc'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassmorphicCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24.0),
          const SizedBox(height: 12.0),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            desc,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.0,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // --- FORM CONTAINER & SWITCHER ---
  Widget _formContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _headerWidget(),
          const SizedBox(height: 24.0),
          _emailField(),
          if (_currentMode != AuthMode.forgotPassword) ...[
            const SizedBox(height: 16.0),
            _passwordField(),
          ],
          if (_currentMode == AuthMode.login) ...[
            const SizedBox(height: 8.0),
            _forgotPasswordLink(),
          ],
          const SizedBox(height: 24.0),
          _AuthSubmitButton(
            currentMode: _currentMode,
            onPressed: _handleAuthSubmit,
          ),
          const SizedBox(height: 24.0),
          _footerLink(),
        ],
      ),
    );
  }

  Widget _headerWidget() {
    switch (_currentMode) {
      case AuthMode.forgotPassword:
        return AuthHeaderWidget(
          title: context.tr('forgot_password_title'),
          subtitle: context.tr('forgot_password_sub'),
        );
      case AuthMode.login:
        return AuthHeaderWidget(
          title: context.tr('welcome_back_title'),
          subtitle: context.tr('welcome_back_sub'),
        );
    }
  }

  Widget _emailField() {
    return AppTextField(
      controller: _emailController,
      label: context.tr('email_address'),
      hint: 'name@brokerhive.com',
      keyboardType: TextInputType.emailAddress,
      textInputAction: _currentMode == AuthMode.forgotPassword
          ? TextInputAction.done
          : TextInputAction.next,
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: AppColors.iconDefault,
      ),
      validator: (val) {
        if (val.isEmptyORNull) return context.tr('email_required');
        if (!val.isEmail) return context.tr('valid_email_required');
        return null;
      },
    );
  }

  Widget _passwordField() {
    return PasswordFieldWidget(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      label: context.tr('password'),
      textInputAction: TextInputAction.done,
      validator: (val) {
        if (val.isEmptyORNull) return context.tr('password_required');
        return null;
      },
    );
  }

  Widget _forgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _switchMode(AuthMode.forgotPassword),
        child: Text(
          context.tr('forgot_password_link'),
          style: AppTextStyles.body2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _footerLink() {
    if (_currentMode == AuthMode.forgotPassword) {
      return AuthFooterLinkWidget(
        mainText: context.tr('remember_password'),
        actionText: context.tr('sign_in'),
        onTap: () => _switchMode(AuthMode.login),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _copyrightFooter() {
    return Text(
      context.tr('copyright_text'),
      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      textAlign: TextAlign.center,
    );
  }
}

/// Extracted widget so context.select lives in its own BuildContext.
/// Only THIS widget rebuilds when isLoading changes — the parent form is untouched.
class _AuthSubmitButton extends StatelessWidget {
  final AuthMode currentMode;
  final VoidCallback onPressed;

  const _AuthSubmitButton({required this.currentMode, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>((p) => p.isLoading);

    String buttonText = context.tr('sign_in_dashboard');
    if (currentMode == AuthMode.forgotPassword) {
      buttonText = context.tr('send_reset_link');
    }

    return RoundedButton(
      text: buttonText,
      variant: ButtonVariant.gradient,
      isLoading: isLoading,
      icon: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 18.0,
      ),
      onPressed: onPressed,
    ).disable(isDisable: isLoading);
  }
}
