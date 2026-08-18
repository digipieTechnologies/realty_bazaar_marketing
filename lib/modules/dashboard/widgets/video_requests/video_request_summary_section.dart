// File: lib/modules/dashboard/widgets/video_requests/video_request_summary_section.dart
// Purpose: Reusable metric summary card section for video shoot requests.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/app_text_styles.dart';
import '../../../../util/common_ext.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../widgets/common/app_card_container.dart';

class VideoRequestSummarySection extends StatelessWidget {
  final int totalRequests;
  final int pendingRequests;
  final int inProgressRequests;
  final int completedRequests;
  final bool isExpanded;
  final VoidCallback onToggle;

  const VideoRequestSummarySection({
    super.key,
    required this.totalRequests,
    required this.pendingRequests,
    required this.inProgressRequests,
    required this.completedRequests,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = !context.isDesktopUI;

    return AppCardContainer(
      borderRadius: 12.0,
      onTap: onToggle,
      padding: const EdgeInsets.all(16.0),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('summary'),
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 16.0,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 24.0,
                    ),
                  ],
                ),

                // Expanded Grid Content
                if (isExpanded) ...[
                  const SizedBox(height: 16.0),
                  isMobile
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    context.tr('total_requests'),
                                    '$totalRequests',
                                    context.tr('across_all_listings'),
                                    Icons.trending_up,
                                    AppColors.success,
                                    isMobile: true,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: _buildSummaryCard(
                                    context.tr('pending_shoots'),
                                    '$pendingRequests',
                                    context.tr('needs_review'),
                                    Icons.hourglass_empty_rounded,
                                    AppColors.warning,
                                    isMobile: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    context.tr('in_progress_shoots'),
                                    '$inProgressRequests',
                                    context.tr('field_team_assigned'),
                                    Icons.run_circle_outlined,
                                    AppColors.info,
                                    isMobile: true,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: _buildSummaryCard(
                                    context.tr('completed_shoots'),
                                    '$completedRequests',
                                    context.tr('uploaded_to_listings'),
                                    Icons.check_circle_outline,
                                    AppColors.success,
                                    isMobile: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                context.tr('total_requests'),
                                '$totalRequests',
                                context.tr('across_all_listings'),
                                Icons.trending_up,
                                AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: _buildSummaryCard(
                                context.tr('pending_shoots'),
                                '$pendingRequests',
                                context.tr('needs_review'),
                                Icons.hourglass_empty_rounded,
                                AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: _buildSummaryCard(
                                context.tr('in_progress_shoots'),
                                '$inProgressRequests',
                                context.tr('field_team_assigned'),
                                Icons.run_circle_outlined,
                                AppColors.info,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: _buildSummaryCard(
                                context.tr('completed_shoots'),
                                '$completedRequests',
                                context.tr('uploaded_to_listings'),
                                Icons.check_circle_outline,
                                AppColors.success,
                              ),
                            ),
                          ],
                        ),
                ],
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color, {
    bool isMobile = false,
  }) {
    return AppCardContainer(
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      borderRadius: 12.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 11.5 : 13.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: isMobile ? 20.0 : 26.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(isMobile ? 5.0 : 6.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 14.0 : 18.0,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 10.5 : 12.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
