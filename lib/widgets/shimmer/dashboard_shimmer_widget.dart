import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../util/common_ext.dart';
import 'app_shimmer_container.dart';
import 'stat_card_shimmer_widget.dart';

import '../../app/app_constants.dart';

class DashboardShimmerWidget extends StatelessWidget {
  const DashboardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopUI;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // 1. Top Navigation Bar Shimmer
          _buildTopBarShimmer(isDesktop),

          // 2. Main Scrollable Dashboard Content Shimmer
          Expanded(
            child: SingleChildScrollView(
              padding: AppConstants.getTabPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header Card Skeleton
                  const _CardSkeleton(height: 110),
                  const SizedBox(height: 28.0),
                  const Divider(height: 1.0, color: AppColors.border),
                  const SizedBox(height: 24.0),

                  // Section Header 1: Campaign Performance Overview Skeleton
                  const _SectionHeaderSkeleton(),
                  const SizedBox(height: 12.0),

                  // 4 Stat Cards Grid Skeleton
                  GridView.count(
                    crossAxisCount: isDesktop ? 4 : 1,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isDesktop ? 1.4 : 2.5,
                    children: [
                      StatCardSkeleton(isDesktop: isDesktop),
                      StatCardSkeleton(isDesktop: isDesktop),
                      StatCardSkeleton(isDesktop: isDesktop),
                      StatCardSkeleton(isDesktop: isDesktop),
                    ],
                  ),
                  const SizedBox(height: 28.0),
                  const Divider(height: 1.0, color: AppColors.border),
                  const SizedBox(height: 24.0),

                  // Section Header 2: Recent Activity & Campaigns Skeleton
                  const _SectionHeaderSkeleton(),
                  const SizedBox(height: 12.0),

                  // Recent Campaigns & Quick Actions Layout Skeleton
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        flex: 2,
                        child: _CardSkeleton(height: 280),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 24.0),
                        const Expanded(
                          flex: 1,
                          child: _CardSkeleton(height: 280),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarShimmer(bool isDesktop) {
    return Container(
      height: 70.0,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: Row(
        children: [
          // Screen Label Shimmer
          const AppShimmerContainer(width: 120, height: 20),
          const Spacer(),

          // Search Box Shimmer
          if (isDesktop) ...[
            const AppShimmerContainer(
              width: 240,
              height: 38,
              borderRadius: 8.0,
            ),
            const SizedBox(width: 16.0),
          ],

          // Notification / Help Action Icon Shimmers
          const AppShimmerContainer(width: 36, height: 36, borderRadius: 18.0),
          const SizedBox(width: 12.0),
          const AppShimmerContainer(width: 36, height: 36, borderRadius: 18.0),

          if (isDesktop) ...[
            const SizedBox(width: 16.0),
            const AppShimmerContainer(
              width: 32,
              height: 32,
              borderRadius: 16.0,
            ),
          ],
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  final double height;

  const _CardSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    // Render simplified skeletons for shorter boxes (like Quick Actions) to prevent overflow
    if (height <= 100) {
      return Container(
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppShimmerContainer(width: 22, height: 22, borderRadius: 11.0),
            SizedBox(height: 6.0),
            AppShimmerContainer(width: 55, height: 10),
          ],
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          AppShimmerContainer(width: 140, height: 16),
          SizedBox(height: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppShimmerContainer(width: double.infinity, height: 10),
                SizedBox(height: 8.0),
                AppShimmerContainer(width: double.infinity, height: 10),
                SizedBox(height: 8.0),
                AppShimmerContainer(width: 160, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderSkeleton extends StatelessWidget {
  const _SectionHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          AppShimmerContainer(width: 28, height: 28, borderRadius: 8.0),
          SizedBox(width: 10.0),
          AppShimmerContainer(width: 180, height: 14, borderRadius: 4.0),
        ],
      ),
    );
  }
}
