// File: lib/widgets/shimmer/video_request_details_shimmer_widget.dart
// Purpose: Shimmer loading widget mimicking the video request details page structure.

import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import 'app_shimmer_container.dart';

class VideoRequestDetailsShimmerWidget extends StatelessWidget {
  final bool isDesktop;

  const VideoRequestDetailsShimmerWidget({
    super.key,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopShimmer();
    } else {
      return _buildMobileShimmer();
    }
  }

  Widget _buildDesktopShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (flex 3): Media Picker & Specs Card
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMediaPickerShimmer(),
                const SizedBox(height: 16.0),
                _buildPropertySpecsShimmer(),
              ],
            ),
          ),
          const SizedBox(width: 20.0),
          // Right Column (flex 2): Address & Broker Card
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressShimmer(),
                const SizedBox(height: 16.0),
                _buildBrokerShimmer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaPickerShimmer(),
          const SizedBox(height: 16.0),
          _buildPropertySpecsShimmer(),
          const SizedBox(height: 16.0),
          _buildAddressShimmer(),
          const SizedBox(height: 16.0),
          _buildBrokerShimmer(),
        ],
      ),
    );
  }

  Widget _buildMediaPickerShimmer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmerContainer(width: 100, height: 16),
          SizedBox(height: 16.0),
          AppShimmerContainer(width: 150, height: 14),
          SizedBox(height: 12.0),
          Row(
            children: [
              AppShimmerContainer(width: 86, height: 86, borderRadius: 14.0),
              SizedBox(width: 12.0),
              AppShimmerContainer(width: 86, height: 86, borderRadius: 14.0),
            ],
          ),
          SizedBox(height: 24.0),
          AppShimmerContainer(width: 180, height: 14),
          SizedBox(height: 12.0),
          Row(
            children: [
              AppShimmerContainer(width: 86, height: 86, borderRadius: 14.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertySpecsShimmer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerContainer(width: 120, height: 16),
              AppShimmerContainer(width: 70, height: 22, borderRadius: 8.0),
            ],
          ),
          const SizedBox(height: 16.0),
          const AppShimmerContainer(width: 250, height: 24),
          const SizedBox(height: 8.0),
          const AppShimmerContainer(width: double.infinity, height: 14),
          const SizedBox(height: 6.0),
          const AppShimmerContainer(width: 200, height: 14),
          const SizedBox(height: 20.0),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16.0),
          // Specs Grid items using a wrap
          LayoutBuilder(
            builder: (context, gridConstraints) {
              final totalWidth = gridConstraints.maxWidth;
              final columns = totalWidth < 500 ? 2 : 3;
              const spacing = 12.0;
              final itemWidth = (totalWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(6, (index) {
                  return AppShimmerContainer(
                    width: itemWidth,
                    height: 60.0,
                    borderRadius: 12.0,
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressShimmer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmerContainer(width: 80, height: 16),
          SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmerContainer(width: 24, height: 24, borderRadius: 12.0),
              SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmerContainer(width: double.infinity, height: 14),
                    SizedBox(height: 6.0),
                    AppShimmerContainer(width: 150, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrokerShimmer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmerContainer(width: 100, height: 16),
          SizedBox(height: 16.0),
          Row(
            children: [
              AppShimmerContainer(width: 44, height: 44, borderRadius: 22.0),
              SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerContainer(width: 150, height: 14),
                  SizedBox(height: 6.0),
                  AppShimmerContainer(width: 80, height: 12),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Divider(color: AppColors.border),
          SizedBox(height: 16.0),
          AppShimmerContainer(width: 100, height: 14),
          SizedBox(height: 8.0),
          AppShimmerContainer(width: double.infinity, height: 44, borderRadius: 10.0),
        ],
      ),
    );
  }
}
