// File: lib/modules/dashboard/screens/video_requests_tab_screen.dart
// Purpose: Manage video shoot requests submitted by brokers for properties without media.

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../widgets/buttons/rounded_button.dart';
import '../../../widgets/containers/container_corner.dart';
import '../../../widgets/inputs/app_textfield.dart';
import '../../../widgets/toast/app_toast.dart';
import '../../../widgets/dialogs/app_dialog.dart';
import '../../../providers/video_request/video_request_provider.dart';
import '../../../models/models.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../app/app_utils.dart';
import '../widgets/video_requests/video_request_summary_section.dart';
import '../widgets/video_requests/video_request_table_widget.dart';

import '../../../app/app_constants.dart';

class VideoRequestsTabScreen extends StatefulWidget {
  const VideoRequestsTabScreen({super.key});

  @override
  State<VideoRequestsTabScreen> createState() => _VideoRequestsTabScreenState();
}

class _VideoRequestsTabScreenState extends State<VideoRequestsTabScreen> {
  final _searchDebouncer = AppUtils.debounce(milliseconds: 300);
  final _storage = GetStorage();
  bool _isStatsExpanded = true;
  VideoRequestProvider? _videoRequestProvider;

  @override
  void initState() {
    super.initState();
    _isStatsExpanded = _storage.read<bool>('video_requests_stats_expanded') ?? true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _videoRequestProvider = context.read<VideoRequestProvider>();
      _videoRequestProvider?.fetchVideoRequestCounts();
      _videoRequestProvider?.fetchVideoRequests(page: 1);
      _videoRequestProvider?.subscribeToRealtimeChanges();
    });
  }

  @override
  void dispose() {
    _videoRequestProvider?.unsubscribeFromRealtimeChanges();
    super.dispose();
  }

  Future<void> _handleAccept(VideoRequestModel req) async {
    final confirmed = await AppDialog.showConfirmationDialog(
      context,
      title: context.tr('confirm_accept_title'),
      description: context.tr('confirm_accept_msg'),
      type: DialogType.info,
      confirmText: context.tr('accept'),
      cancelText: context.tr('cancel'),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<VideoRequestProvider>();
    final success = await provider.updateRequestStatus(req.id, VideoRequestStatus.inProgress);
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess(
        context.tr('request_accepted'),
        context.tr('shoot_moved_in_progress'),
      );
    } else {
      AppToast.showError(
        context.tr('operation_failed'),
        context.tr('failed_to_update_request'),
      );
    }
  }

  Future<void> _handleDecline(VideoRequestModel req) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ContainerCorner(
            width: 400.0,
            color: AppColors.surface,
            borderRadius: 16.0,
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Center(
                    child: ContainerCorner(
                      width: 56.0,
                      height: 56.0,
                      borderRadius: 28.0,
                      color: AppColors.error.withValues(alpha: 0.1),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 32.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Title
                  Center(
                    child: Text(
                      context.tr('confirm_decline_title'),
                      style: AppTextStyles.heading3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Message
                  Center(
                    child: Text(
                      context.tr('confirm_decline_msg'),
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Reason Input using AppTextField (separate label text above box)
                  AppTextField(
                    controller: reasonController,
                    label: context.tr('decline_reason'),
                    hint: context.tr('enter_decline_reason'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.tr('decline_reason_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButton(
                          text: context.tr('cancel'),
                          variant: ButtonVariant.outline,
                          borderColor: AppColors.border,
                          textStyle: AppTextStyles.button.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(null),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: RoundedButton(
                          text: context.tr('decline'),
                          variant: ButtonVariant.solid,
                          color: AppColors.error,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.of(ctx).pop(reasonController.text.trim());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (reason == null || reason.isEmpty || !mounted) return;

    final provider = context.read<VideoRequestProvider>();
    final success = await provider.cancelRequest(req.id, reason: reason);
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess(
        context.tr('request_declined'),
        context.tr('shoot_declined_msg'),
      );
    } else {
      AppToast.showError(
        context.tr('operation_failed'),
        context.tr('failed_to_update_request'),
      );
    }
  }

  Future<void> _handleUpload(VideoRequestModel req) async {
    final provider = context.read<VideoRequestProvider>();
    final success = await provider.updateRequestStatus(req.id, VideoRequestStatus.completed);
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess(
        context.tr('media_uploaded'),
        context.tr('media_uploaded_msg'),
      );
    } else {
      AppToast.showError(
        context.tr('operation_failed'),
        context.tr('failed_to_update_request'),
      );
    }
  }

  Future<void> _handleDelete(VideoRequestModel req) async {
    final provider = context.read<VideoRequestProvider>();
    final success = await provider.deleteRequest(req.id);
    if (!mounted) return;
    if (success) {
      AppToast.showSuccess(
        context.tr('request_deleted'),
        context.tr('request_deleted_msg'),
      );
    } else {
      AppToast.showError(
        context.tr('operation_failed'),
        context.tr('failed_to_update_request'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Consumer<VideoRequestProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: AppConstants.getTabPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Summary Section Card Widgets
              VideoRequestSummarySection(
                totalRequests: provider.totalRequests,
                pendingRequests: provider.pendingRequests,
                inProgressRequests: provider.inProgressRequests,
                completedRequests: provider.completedRequests,
                isExpanded: _isStatsExpanded,
                onToggle: () {
                  setState(() {
                    _isStatsExpanded = !_isStatsExpanded;
                    _storage.write('video_requests_stats_expanded', _isStatsExpanded);
                  });
                },
              ),
              SizedBox(height: isMobile ? 14.0 : 24.0),

              // 2. Main Table Layout Container Widget
              VideoRequestTableWidget(
                requests: provider.requests,
                isLoading: provider.isLoading,
                currentPage: provider.currentPage,
                totalPages: provider.totalPages,
                totalItems: provider.totalItems,
                itemsPerPage: provider.itemsPerPage,
                onSearchChanged: (value) {
                  _searchDebouncer(() {
                    provider.fetchVideoRequests(page: 1, searchQuery: value);
                  });
                },
                onPageChanged: (page) {
                  provider.fetchVideoRequests(page: page, searchQuery: provider.searchQuery);
                },
                onViewDetails: (req) {
                  context.push('/video-request-details/${req.id}');
                },
                onAccept: _handleAccept,
                onDecline: _handleDecline,
                onUpload: _handleUpload,
                onDelete: _handleDelete,
                statusesFilter: provider.statusesFilter,
                onStatusesFilterChanged: (newStatuses) {
                  provider.setStatusesFilter(newStatuses);
                  provider.fetchVideoRequests(page: 1, searchQuery: provider.searchQuery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
