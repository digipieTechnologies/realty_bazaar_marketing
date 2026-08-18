// File: lib/widgets/shimmer/broker_list_shimmer_widget.dart
// Purpose: Reusable shimmer placeholder loading effect for the brokers list in desktop & mobile.

import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import 'app_shimmer_container.dart';

class BrokerListShimmerWidget extends StatelessWidget {
  final int count;
  final bool isMobile;

  const BrokerListShimmerWidget({
    super.key,
    this.count = 5,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        itemCount: count,
        separatorBuilder: (context, index) => const SizedBox(height: 12.0),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppShimmerContainer(width: 44, height: 44, borderRadius: 22.0),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerContainer(width: 140, height: 14, borderRadius: 4.0),
                        SizedBox(height: 6.0),
                        AppShimmerContainer(width: 90, height: 11, borderRadius: 4.0),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.0),
              Row(
                children: [
                  AppShimmerContainer(width: 24, height: 24, borderRadius: 12.0),
                  SizedBox(width: 8.0),
                  AppShimmerContainer(width: 24, height: 24, borderRadius: 12.0),
                  Spacer(),
                  AppShimmerContainer(width: 120, height: 12, borderRadius: 4.0),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 1.0),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: const Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  AppShimmerContainer(width: 40, height: 40, borderRadius: 20.0),
                  SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppShimmerContainer(width: 120, height: 14, borderRadius: 4.0),
                        SizedBox(height: 6.0),
                        AppShimmerContainer(width: 80, height: 11, borderRadius: 4.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  AppShimmerContainer(width: 24, height: 24, borderRadius: 12.0),
                  SizedBox(width: 6.0),
                  AppShimmerContainer(width: 80, height: 12, borderRadius: 4.0),
                ],
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppShimmerContainer(width: 110, height: 12, borderRadius: 4.0),
                  SizedBox(height: 4.0),
                  AppShimmerContainer(width: 140, height: 11, borderRadius: 4.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
