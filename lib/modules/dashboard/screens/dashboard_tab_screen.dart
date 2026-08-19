// File: lib/modules/dashboard/screens/dashboard_tab_screen.dart
// Purpose: Primary Dashboard tab showing ads conversion stats, metrics, and campaign overview.

import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/services/permission_service.dart';
import '../../../util/common_ext.dart';
import '../../../widgets/common/app_card_container.dart';
import '../../../widgets/common/app_section_header.dart';

import '../../../app/app_constants.dart';

class DashboardTabScreen extends StatefulWidget {
  const DashboardTabScreen({super.key});

  @override
  State<DashboardTabScreen> createState() => _DashboardTabScreenState();
}

class _DashboardTabScreenState extends State<DashboardTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestNotificationPermissionDirectly();
    });
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileUI;

    return SingleChildScrollView(
      padding: AppConstants.getTabPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 16.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Realty Marketing',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Monitor leads, manage marketing requests, and scale campaign outreach across platforms.',
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28.0),
          const Divider(height: 1.0, color: AppColors.border),
          const SizedBox(height: 24.0),

          // Stats Grid Header
          const AppSectionHeader(
            title: 'Campaign Performance Overview',
            icon: Icons.insights_rounded,
          ),
          const SizedBox(height: 4.0),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 4,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isMobile ? 2.5 : 1.4,
            children: [
              _buildStatCard(
                title: 'Active Campaigns',
                value: '12',
                subtitle: '+3 this week',
                icon: Icons.campaign_rounded,
                color: AppColors.primary,
              ),
              _buildStatCard(
                title: 'Leads Recieved',
                value: '1,482',
                subtitle: '+18% growth',
                icon: Icons.people_alt_rounded,
                color: AppColors.secondary,
              ),
              _buildStatCard(
                title: 'Video Requests',
                value: '8 Pending',
                subtitle: 'Marketing team active',
                icon: Icons.video_camera_back_rounded,
                color: AppColors.warning,
              ),
              _buildStatCard(
                title: 'Total Ad Spend',
                value: '\$4,250',
                subtitle: 'ROI: 4.8x',
                icon: Icons.payments_rounded,
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 28.0),
          const Divider(height: 1.0, color: AppColors.border),
          const SizedBox(height: 24.0),

          // Recent Activity Header
          const AppSectionHeader(
            title: 'Recent Activity & Campaigns',
            icon: Icons.campaign_rounded,
          ),
          const SizedBox(height: 4.0),

          // Recent Activity & Quick Actions Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Campaigns List
              Expanded(
                flex: isMobile ? 1 : 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Ad Campaigns',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final campaigns = [
                              {
                                'title': 'Sunset Heights Premium Video Ad',
                                'channel': 'Facebook & Instagram Ads',
                                'leads': '148',
                                'status': 'Active',
                                'statusColor': AppColors.success,
                              },
                              {
                                'title': 'Oakwood Residence Slideshow Reel',
                                'channel': 'Instagram Reels Campaign',
                                'leads': '95',
                                'status': 'Active',
                                'statusColor': AppColors.success,
                              },
                              {
                                'title': 'Downtown Skyline Single Media Post',
                                'channel': 'Facebook Marketplace Ad',
                                'leads': '214',
                                'status': 'Completed',
                                'statusColor': AppColors.textMuted,
                              },
                            ];
                            final campaign = campaigns[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: (campaign['statusColor'] as Color).withValues(alpha: 0.1),
                                    child: Icon(
                                      Icons.ads_click_rounded,
                                      color: campaign['statusColor'] as Color,
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          campaign['title'] as String,
                                          style: AppTextStyles.body2.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          campaign['channel'] as String,
                                          style: AppTextStyles.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${campaign['leads']} Leads',
                                        style: AppTextStyles.body2.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: (campaign['statusColor'] as Color).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          campaign['status'] as String,
                                          style: AppTextStyles.caption.copyWith(
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.bold,
                                            color: campaign['statusColor'] as Color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (!isMobile) ...[
                const SizedBox(width: 24.0),
                // Side info column
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marketing Guidelines',
                            style: AppTextStyles.heading3.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          _buildGuidelineItem(
                            icon: Icons.video_settings_rounded,
                            title: 'HD Walkthrough Shoot',
                            desc: 'Always use 1080p 60fps vertical layout for Instagram and Facebook Reels.',
                          ),
                          const Divider(height: 24.0),
                          _buildGuidelineItem(
                            icon: Icons.spatial_audio_off_rounded,
                            title: 'Trending Audio Integration',
                            desc: 'Use dynamic background tracks to maximize reach and organic suggestions.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return AppCardContainer(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 16.0,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24.0),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                desc,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
