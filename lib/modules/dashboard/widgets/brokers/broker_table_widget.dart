// File: lib/modules/dashboard/widgets/brokers/broker_table_widget.dart
// Purpose: Reusable table and list container widget for brokers registry with search & pagination.

import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../models/models.dart';
import '../../../../util/common_ext.dart';
import '../../../../widgets/common/app_card_container.dart';
import '../../../../widgets/common/app_empty_state_widget.dart';
import '../../../../widgets/common/app_pagination_widget.dart';
import '../../../../widgets/shimmer/broker_list_shimmer_widget.dart';
import 'broker_tile_widget.dart';

class BrokerTableWidget extends StatelessWidget {
  final List<UserModel> brokers;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<String>? onSearchChanged;

  const BrokerTableWidget({
    super.key,
    required this.brokers,
    this.isLoading = false,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final useTileView = !context.isDesktopUI;

    return AppCardContainer(
      borderRadius: 16.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field Header Row
          Padding(
            padding: EdgeInsets.all(useTileView ? 12.0 : 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    child: TextField(
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        hintText: context.tr('search_brokers_hint'),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 18.0,
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Desktop Table Header Row
          if (!useTileView)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1.0),
                  bottom: BorderSide(color: AppColors.border, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      context.tr('broker_name'),
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      context.tr('connected_accounts'),
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      context.tr('contact_details'),
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Shimmer or List or Empty State
          if (isLoading)
            BrokerListShimmerWidget(count: 5, isMobile: useTileView)
          else if (brokers.isEmpty)
            AppEmptyStateWidget(
              icon: Icons.people_outline_rounded,
              title: context.tr('no_brokers_found'),
              description: context.tr('no_brokers_empty_desc'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: useTileView
                  ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)
                  : EdgeInsets.zero,
              itemCount: brokers.length,
              itemBuilder: (context, index) {
                final broker = brokers[index];
                return BrokerTileWidget(broker: broker, isMobile: useTileView);
              },
            ),

          // Pagination Footer Widget
          AppPaginationWidget(
            currentPage: currentPage,
            totalPages: totalPages,
            totalItems: totalItems,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}
