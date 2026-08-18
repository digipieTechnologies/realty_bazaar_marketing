// File: lib/modules/dashboard/widgets/video_requests/video_request_table_widget.dart
// Purpose: Main table layout wrapper widget for video requests.

import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/app_text_styles.dart';
import '../../../../util/common_ext.dart';
import '../../../../widgets/common/app_card_container.dart';
import '../../../../widgets/common/app_empty_state_widget.dart';
import '../../../../widgets/common/app_filter_popup.dart';
import '../../../../widgets/common/app_pagination_widget.dart';
import '../../../../models/models.dart';
import '../../../../widgets/shimmer/video_request_list_shimmer_widget.dart';
import 'video_request_filter_popover.dart';
import 'video_request_tile_widget.dart';

class VideoRequestTableWidget extends StatefulWidget {
  final List<VideoRequestModel> requests;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onPageChanged;
  final Function(VideoRequestModel) onViewDetails;
  final Function(VideoRequestModel) onAccept;
  final Function(VideoRequestModel) onDecline;
  final Function(VideoRequestModel) onUpload;
  final Function(VideoRequestModel) onDelete;
  final List<VideoRequestStatus>? statusesFilter;
  final ValueChanged<List<VideoRequestStatus>>? onStatusesFilterChanged;

  const VideoRequestTableWidget({
    super.key,
    required this.requests,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onSearchChanged,
    required this.onPageChanged,
    required this.onViewDetails,
    required this.onAccept,
    required this.onDecline,
    required this.onUpload,
    required this.onDelete,
    this.statusesFilter,
    this.onStatusesFilterChanged,
  });

  @override
  State<VideoRequestTableWidget> createState() => _VideoRequestTableWidgetState();
}

class _VideoRequestTableWidgetState extends State<VideoRequestTableWidget> {
  List<VideoRequestStatus> _localStatusesFilter = [];

  @override
  void initState() {
    super.initState();
    _localStatusesFilter = widget.statusesFilter ?? [];
  }

  @override
  void didUpdateWidget(covariant VideoRequestTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statusesFilter != oldWidget.statusesFilter) {
      setState(() {
        _localStatusesFilter = widget.statusesFilter ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final useTileView = !context.isDesktopUI;

    return AppCardContainer(
      borderRadius: 16.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar Row with Search Input & Filter Button
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
                      onChanged: widget.onSearchChanged,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        hintText: 'Search property, location, broker...',
                        prefixIcon: Icon(
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
                const SizedBox(width: 12.0),
                AppFilterButton(
                  title: 'Filter Requests',
                  onClear: () {
                    setState(() {
                      _localStatusesFilter = [];
                    });
                    if (widget.onStatusesFilterChanged != null) {
                      widget.onStatusesFilterChanged!([]);
                    }
                  },
                  onApply: () {
                    if (widget.onStatusesFilterChanged != null) {
                      widget.onStatusesFilterChanged!(_localStatusesFilter);
                    }
                  },
                  child: VideoRequestFilterPopover(
                    selectedStatuses: _localStatusesFilter,
                    onStatusesChanged: (updated) {
                      setState(() {
                        _localStatusesFilter = updated;
                      });
                    },
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
                    flex: 3,
                    child: Text(
                      'PROPERTY DETAILS',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'REQUESTED BY',
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
                      'BROKER NOTES',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'STATUS',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                    child: Text(''),
                  ),
                ],
              ),
            ),

          // Table Body
          widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: VideoRequestListShimmerWidget(),
                )
              : widget.requests.isEmpty
                  ? const AppEmptyStateWidget(
                      icon: Icons.video_library_outlined,
                      title: 'No requests found',
                      description: 'No video shoot requests found matching your current search or filter selection.',
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: useTileView ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0) : EdgeInsets.zero,
                      itemCount: widget.requests.length,
                      itemBuilder: (context, index) {
                        final req = widget.requests[index];
                        return VideoRequestTileWidget(
                          req: req,
                          isMobile: useTileView,
                          onViewDetailsPressed: () => widget.onViewDetails(req),
                          onAcceptPressed: () => widget.onAccept(req),
                          onDeclinePressed: () => widget.onDecline(req),
                          onUploadPressed: () => widget.onUpload(req),
                          onDeletePressed: () => widget.onDelete(req),
                        );
                      },
                    ),

          // Pagination Footer Widget
          AppPaginationWidget(
            currentPage: widget.currentPage,
            totalPages: widget.totalPages,
            totalItems: widget.totalItems,
            itemsPerPage: widget.itemsPerPage,
            itemLabel: 'requests',
            onPageChanged: widget.onPageChanged,
          ),
        ],
      ),
    );
  }
}
