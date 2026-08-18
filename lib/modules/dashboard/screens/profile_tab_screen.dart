import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/app_routes.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../widgets/common/app_card_container.dart';

import '../../../app/app_constants.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  void _handleSignOut() async {
    final auth = context.read<AuthProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('confirm_sign_out')),
        content: Text(context.tr('sign_out_warning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr('sign_out_button')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await auth.signOut();
      if (mounted) {
        AppRoutes.router.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().userProfile;
    final String name = profile?.name ?? 'Alex Marketing';
    final String role = (profile?.role?.displayName ?? 'Marketing Exec').toUpperCase();
    final String email = profile?.email ?? 'marketing@brokerhive.com';
    final String phone = profile?.phone ?? '+91 98765 43210';
    return SingleChildScrollView(
      padding: AppConstants.getTabPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          AppCardContainer(
            padding: const EdgeInsets.all(24.0),
            borderRadius: 16.0,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.primary,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 24.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          role,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Details List
          Text(
            context.tr('personal_details').toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12.0),
          AppCardContainer(
            borderRadius: 16.0,
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                  title: Text(context.tr('full_name')),
                  subtitle: Text(name),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  title: Text(context.tr('email_address')),
                  subtitle: Text(email),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                  title: Text(context.tr('phone_number')),
                  subtitle: Text(phone),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),

          // Actions
          Text(
            context.tr('account_actions').toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12.0),
          AppCardContainer(
            borderRadius: 16.0,
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text(
                context.tr('sign_out_button'),
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(context.tr('sign_out_subtitle')),
              onTap: _handleSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
