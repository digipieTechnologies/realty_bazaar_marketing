// File: lib/modules/dashboard/widgets/brokers/broker_tile_widget.dart
// Purpose: Reusable broker tile widget supporting both desktop table row & modern mobile card layouts with connected social account details.

import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../models/models.dart';
import '../../../../widgets/common/app_card_container.dart';
import '../../../../widgets/common/user_avatar_widget.dart';
import '../../../../widgets/icons/app_icons.dart';

class BrokerTileWidget extends StatelessWidget {
  final UserModel broker;
  final bool isMobile;
  final VoidCallback? onTap;

  const BrokerTileWidget({
    super.key,
    required this.broker,
    this.isMobile = false,
    this.onTap,
  });

  Widget _buildConnectedAccountsWidget({bool hideEmpty = false}) {
    final accounts = broker.socialAccounts ?? [];
    final connectedAccounts = accounts.where((a) => (a.isConnected ?? true) && (a.isActive ?? true)).toList();

    if (connectedAccounts.isEmpty) {
      if (hideEmpty) return const SizedBox.shrink();
      return Text(
        '--',
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
          fontSize: 13.0,
        ),
      );
    }

    final chips = <Widget>[];

    for (final acc in connectedAccounts) {
      if (acc.platform == SocialPlatform.facebook) {
        final name = acc.pageName?.trim().isNotEmpty == true
            ? acc.pageName!.trim()
            : 'Facebook Page';
        chips.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: const Color(0xFF1877F2).withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FacebookIconWidget(size: 16.0),
                const SizedBox(width: 6.0),
                Flexible(
                  child: Text(
                    name,
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF1877F2),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (acc.platform == SocialPlatform.instagram) {
        final username = acc.instagramUsername?.trim().isNotEmpty == true
            ? '@${acc.instagramUsername!.trim().replaceAll('@', '')}'
            : (acc.pageName?.trim().isNotEmpty == true ? acc.pageName!.trim() : 'Instagram');
        chips.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE4405F).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: const Color(0xFFE4405F).withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const InstagramIconWidget(size: 16.0),
                const SizedBox(width: 6.0),
                Flexible(
                  child: Text(
                    username,
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFE4405F),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (chips.isEmpty) {
      if (hideEmpty) return const SizedBox.shrink();
      return Text(
        '--',
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
          fontSize: 13.0,
        ),
      );
    }

    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: chips,
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessName = broker.brokerId?.businessName;
    final hasBusinessName = businessName != null && businessName.trim().isNotEmpty;
    final phone = broker.phone != null && broker.phone!.isNotEmpty
        ? '+${broker.phoneCountryCode ?? "91"} ${broker.phone}'
        : '--';
    final email = broker.email != null && broker.email!.isNotEmpty ? broker.email! : '--';

    final accounts = broker.socialAccounts ?? [];
    final hasConnectedAccounts = accounts.any((a) => (a.isConnected ?? true) && (a.isActive ?? true));

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: AppCardContainer(
          borderRadius: 16.0,
          onTap: onTap,
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Avatar, Broker Name, Business Subtitle
                Row(
                  crossAxisAlignment: hasBusinessName ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    UserAvatarWidget(
                      name: broker.name ?? 'Broker',
                      radius: 22.0,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            broker.name ?? 'Broker',
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (hasBusinessName) ...[
                            const SizedBox(height: 3.0),
                            Text(
                              businessName,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Connected Social Accounts Section (Only if connected accounts exist)
                if (hasConnectedAccounts) ...[
                  const SizedBox(height: 14.0),
                  Text(
                    context.tr('connected_accounts').toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  _buildConnectedAccountsWidget(hideEmpty: true),
                ],

                // Contact Phone & Email Section
                if (phone != '--' || email != '--') ...[
                  const SizedBox(height: 14.0),
                  const Divider(height: 1.0, color: AppColors.border),
                  const SizedBox(height: 12.0),

                  if (phone != '--')
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 14.0,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          phone,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),

                  if (phone != '--' && email != '--') const SizedBox(height: 6.0),

                  if (email != '--')
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 14.0,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            email,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ],
            ),
        ),
      );
    }

    // Desktop Table Row Layout
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        child: Row(
          children: [
            // Broker Name & Business Subtitle
            Expanded(
              flex: 4,
              child: Row(
                crossAxisAlignment: hasBusinessName ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  UserAvatarWidget(
                    name: broker.name ?? 'Broker',
                    radius: 20.0,
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          broker.name ?? 'Broker',
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasBusinessName) ...[
                          const SizedBox(height: 2.0),
                          Text(
                            businessName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),

            // Connected Accounts (FB Page Name & IG Username)
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildConnectedAccountsWidget(),
              ),
            ),
            const SizedBox(width: 12.0),

            // Contact Details (Phone & Email)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phone,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      fontSize: 13.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    email,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
