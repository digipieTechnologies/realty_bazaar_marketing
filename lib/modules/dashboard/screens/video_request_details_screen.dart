// File: lib/modules/dashboard/screens/video_request_details_screen.dart
// Purpose: Modern standalone screen for video request details, property inspection, and media upload management.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/models.dart';
import '../../../providers/video_request/video_request_provider.dart';
import '../../../widgets/inputs/app_square_media_picker.dart';
import '../../../widgets/toast/app_toast.dart';
import '../../../widgets/buttons/rounded_button.dart';
import '../../../widgets/common/common_app_bar.dart';
import '../../../widgets/shimmer/video_request_details_shimmer_widget.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../chat/chat.dart';

class VideoRequestDetailsScreen extends StatefulWidget {
  final String requestId;

  const VideoRequestDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<VideoRequestDetailsScreen> createState() => _VideoRequestDetailsScreenState();
}

class _VideoRequestDetailsScreenState extends State<VideoRequestDetailsScreen> {
  bool _isLoading = true;
  VideoRequestModel? _request;
  List<MediaModel> _medias = [];

  // Saving states
  bool _isSaving = false;
  String _saveProgressMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRequestDetails();
  }

  Future<void> _loadRequestDetails() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<VideoRequestProvider>(context, listen: false);
    final req = await provider.fetchRequestById(widget.requestId);

    if (mounted) {
      setState(() {
        _request = req;
        _medias = List<MediaModel>.from(req?.property?.medias ?? []);
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} Lakh';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  Future<void> _saveMediaAndComplete() async {
    if (_request == null || _isSaving) return;

    final provider = Provider.of<VideoRequestProvider>(context, listen: false);
    final mediaSuccessTitle = context.tr('media_uploaded_success');
    final mediaSuccessDesc = context.tr('media_uploaded_success_desc');
    final mediaFailTitle = context.tr('media_upload_failed');
    final mediaFailDesc = context.tr('media_upload_failed_desc');
    final router = GoRouter.of(context);

    setState(() {
      _isSaving = true;
    });

    final success = await provider.savePropertyMedia(
      _request!.id,
      _request!.propertyId ?? '',
      _medias,
      (progress) {
        if (mounted) {
          setState(() {
            _saveProgressMessage = progress;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        AppToast.showSuccess(mediaSuccessTitle, mediaSuccessDesc);
        router.pop();
      } else {
        AppToast.showError(mediaFailTitle, mediaFailDesc);
      }
    }
  }

  Widget _buildMediaPickerCard(VideoRequestModel req) {
    final isCompleted = req.status == VideoRequestStatus.completed;
    final isCancelled = req.status == VideoRequestStatus.cancelled;
    final isReadOnly = isCompleted || isCancelled;
    final cancelReasonStr = req.cancelReason ?? req.adminCancelReason;

    final cardPadding = MediaQuery.of(context).size.width < 600 ? 14.0 : 20.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MEDIA PICKER',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16.0),
          AppSquareMediaPicker(
            medias: _medias,
            readOnly: isReadOnly,
            onMediasChanged: (val) {
              setState(() {
                _medias = val;
              });
            },
          ),
          if (isCompleted) ...[
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20.0),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'This shoot is completed. Media cannot be modified.',
                      style: AppTextStyles.body2.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isCancelled) ...[
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20.0),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          'This request is cancelled. Media cannot be added or modified.',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (cancelReasonStr != null && cancelReasonStr.trim().isNotEmpty) ...[
                    const SizedBox(height: 6.0),
                    Text(
                      'Reason for cancellation: "$cancelReasonStr"',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0.5,
          title: Text(
            context.tr('request_details'),
            style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: VideoRequestDetailsShimmerWidget(isDesktop: isDesktop),
      );
    }

    if (_request == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Request Details Not Found',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 600;
    final bodyPadding = isMobile ? 12.0 : 16.0;

    final req = _request!;
    final prop = req.property;
    final broker = req.broker;
    final isReadOnly = req.status == VideoRequestStatus.completed || req.status == VideoRequestStatus.cancelled;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: CommonAppBar(
            title: prop?.title ?? context.tr('request_details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                tooltip: context.tr('video_request_chat'),
                onPressed: () {
                  final currentUserId = SupabaseConfig.client.auth.currentUser?.id ?? req.brokerId ?? '';
                  showDialog(
                    context: context,
                    builder: (ctx) => ChatDialog(
                      videoRequestId: req.id,
                      brokerId: req.brokerId ?? '',
                      currentUserId: currentUserId,
                      currentUserType: 'marketing',
                      chatTitle: 'Broker',
                      propertyTitle: req.property?.title ?? 'Property Details',
                      propertyAddress: req.property?.title ?? 'Property Details',
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(bodyPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Media & Info (flex: 3)
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMediaPickerCard(req),
                            const SizedBox(height: 16.0),
                            _buildPropertySpecsCard(prop),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      // Right Column: Location & Contact (flex: 2)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAddressCard(prop),
                            const SizedBox(height: 16.0),
                            _buildBrokerCard(broker, req.notes),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMediaPickerCard(req),
                      const SizedBox(height: 16.0),
                      _buildPropertySpecsCard(prop),
                      const SizedBox(height: 16.0),
                      _buildAddressCard(prop),
                      const SizedBox(height: 16.0),
                      _buildBrokerCard(broker, req.notes),
                    ],
                  );
                }
              },
            ),
          ),
          bottomNavigationBar: isReadOnly
              ? null
              : Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RoundedButton(
                        text: _isSaving
                            ? _saveProgressMessage
                            : context.tr('save_complete_shoot'),
                        onPressed: _saveMediaAndComplete,
                        icon: _isSaving
                            ? null
                            : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20.0),
                        isLoading: _isSaving,
                        variant: ButtonVariant.solid,
                        color: AppColors.primary,
                        height: 48.0,
                        borderRadius: 10.0,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPropertySpecsCard(PropertyDetails? prop) {
    if (prop == null) return const SizedBox();

    final priceStr = '₹${_formatCurrency(prop.price)}';
    final areaStr = '${prop.area.toStringAsFixed(0)} ${prop.areaUnit ?? 'Sq.Ft'}';
    final typeStr = prop.propertyType?.toUpperCase() ?? 'APARTMENT';
    final listingTypeStr = prop.listingType == 'rent' ? 'For Rent' : 'For Sale';

    final cardPadding = MediaQuery.of(context).size.width < 600 ? 14.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('property_info'),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  listingTypeStr.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            prop.title,
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
          ),
          if (prop.propertyDescription != null && prop.propertyDescription!.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text(
              prop.propertyDescription!,
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 20.0),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16.0),

          // Specs grid
          LayoutBuilder(
            builder: (context, gridConstraints) {
              final totalWidth = gridConstraints.maxWidth;
              final columns = totalWidth < 500 ? 2 : 3;
              const spacing = 12.0;
              final itemWidth = (totalWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: itemWidth,
                    height: 60.0,
                    child: _buildSpecItem(context.tr('price'), priceStr, Icons.currency_rupee_rounded),
                  ),
                  SizedBox(
                    width: itemWidth,
                    height: 60.0,
                    child: _buildSpecItem(context.tr('area'), areaStr, Icons.square_foot_rounded),
                  ),
                  SizedBox(
                    width: itemWidth,
                    height: 60.0,
                    child: _buildSpecItem('TYPE', typeStr, Icons.home_work_rounded),
                  ),
                  SizedBox(
                    width: itemWidth,
                    height: 60.0,
                    child: _buildSpecItem('BEDROOMS', '${prop.bedrooms} BHK', Icons.bed_rounded),
                  ),
                  SizedBox(
                    width: itemWidth,
                    height: 60.0,
                    child: _buildSpecItem('BATHROOMS', '${prop.bathrooms}', Icons.bathroom_rounded),
                  ),
                  SizedBox(
                    width: itemWidth,
                    height: 60.0,
                    child: _buildSpecItem('PARKING', '${prop.parking}', Icons.local_parking_rounded),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18.0),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 13.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(PropertyDetails? prop) {
    if (prop == null || prop.address == null) return const SizedBox();

    final address = prop.address!;
    final addressParts = [
      address.fullAddress,
      address.city,
      address.state,
      address.pincode
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    final cardPadding = MediaQuery.of(context).size.width < 600 ? 14.0 : 20.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ADDRESS',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.error, size: 22.0),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  addressParts,
                  style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrokerCard(BrokerDetails? broker, String? notes) {
    final cardPadding = MediaQuery.of(context).size.width < 600 ? 14.0 : 20.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('broker_info'),
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          if (broker != null) ...[
            const SizedBox(height: 16.0),
            Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, color: AppColors.secondary, size: 22.0),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        broker.businessName,
                        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (broker.address != null) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          broker.address!.city ?? '',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Broker Notes
          const SizedBox(height: 20.0),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16.0),
          Text(
            context.tr('broker_notes'),
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 12.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              notes == null || notes.trim().isEmpty ? '--' : notes,
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
