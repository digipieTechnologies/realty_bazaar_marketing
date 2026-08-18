// File: lib/providers/video_request/video_request_provider.dart
// Purpose: Manage state and Supabase client calls for the marketing video request dashboard.

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_storage_service.dart';
import '../../core/supabase/supabase_config.dart';
import '../../models/models.dart';

class VideoRequestProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<VideoRequestModel> _requests = [];
  List<VideoRequestModel> get requests => _requests;

  int _totalRequests = 0;
  int get totalRequests => _totalRequests;

  int _pendingRequests = 0;
  int get pendingRequests => _pendingRequests;

  int _inProgressRequests = 0;
  int get inProgressRequests => _inProgressRequests;

  int _completedRequests = 0;
  int get completedRequests => _completedRequests;

  int _cancelledRequests = 0;
  int get cancelledRequests => _cancelledRequests;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  final int _itemsPerPage = 10;
  int get itemsPerPage => _itemsPerPage;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  VideoRequestStatus? _statusFilter = VideoRequestStatus.pending;
  VideoRequestStatus? get statusFilter => _statusFilter;

  List<VideoRequestStatus> _statusesFilter = [VideoRequestStatus.pending];
  List<VideoRequestStatus> get statusesFilter => _statusesFilter;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setStatusFilter(VideoRequestStatus? status) {
    _statusFilter = status;
    if (status != null) {
      _statusesFilter = [status];
    } else {
      _statusesFilter = [];
    }
    notifyListeners();
  }

  void setStatusesFilter(List<VideoRequestStatus> statuses) {
    _statusesFilter = List<VideoRequestStatus>.from(statuses);
    if (_statusesFilter.length == 1) {
      _statusFilter = _statusesFilter.first;
    } else {
      _statusFilter = null;
    }
    notifyListeners();
  }

  /// Fetch summarized request counts from Supabase RPC
  Future<void> fetchVideoRequestCounts() async {
    try {
      final response = await SupabaseConfig.client.rpc(
        'fetch_video_request_counts',
        params: {
          'p_broker_id': null,
          'p_admin_approved_status': VideoRequestApprovalStatus.approved.dbValue,
          'p_status': null,
        },
      );
      if (response != null) {
        final resMap = response is Map<String, dynamic> ? response : {};
        _totalRequests = int.tryParse(resMap['total']?.toString() ?? '0') ?? 0;
        _pendingRequests = int.tryParse(resMap['pending']?.toString() ?? '0') ?? 0;
        _inProgressRequests = int.tryParse(resMap['in_progress']?.toString() ?? '0') ?? 0;
        _completedRequests = int.tryParse(resMap['completed']?.toString() ?? '0') ?? 0;
        _cancelledRequests = int.tryParse(resMap['cancelled']?.toString() ?? '0') ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[VideoRequestProvider] Error calling fetch_video_request_counts RPC: $e');
    }
  }

  /// Fetch paginated video request list with optional search query
  Future<void> fetchVideoRequests({
    int page = 1,
    String searchQuery = '',
  }) async {
    _isLoading = true;
    _currentPage = page;
    _searchQuery = searchQuery;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.client.rpc(
        'fetch_video_requests',
        params: {
          'p_broker_id': null,
          'p_page': page,
          'p_limit': _itemsPerPage,
          'p_search_query': searchQuery,
          'p_admin_approved_status': VideoRequestApprovalStatus.approved.dbValue,
          'p_status': _statusFilter?.dbValue,
          'p_statuses': _statusesFilter.isEmpty ? null : _statusesFilter.map((s) => s.dbValue).toList(),
        },
      );

      if (response != null) {
        final Map<String, dynamic> resMap = response is Map<String, dynamic>
            ? response
            : {};
        
        if (resMap['success'] == true && resMap['data'] is List) {
          final rawList = resMap['data'] as List;
          _requests = rawList
              .map((json) => VideoRequestModel.fromJson(json as Map<String, dynamic>))
              .toList();

          final pagination = resMap['pagination'] as Map<String, dynamic>? ?? {};
          _totalItems = int.tryParse(pagination['total_items']?.toString() ?? '0') ?? _requests.length;
          _totalPages = int.tryParse(pagination['total_pages']?.toString() ?? '1') ?? 1;
          _hasMore = pagination['has_more'] as bool? ?? false;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
          return;
        }
      }
      _errorMessage = 'Failed to fetch video requests.';
    } catch (e) {
      debugPrint('[VideoRequestProvider] Error calling fetch_marketing_video_requests RPC: $e');
      _errorMessage = e.toString();
    }

    _requests = [];
    _totalItems = 0;
    _totalPages = 1;
    _hasMore = false;
    _isLoading = false;
    notifyListeners();
  }

  /// Update video request status (assigned, in_progress, completed, cancelled)
  Future<bool> updateRequestStatus(String requestId, VideoRequestStatus newStatus, {String? notes}) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus.dbValue,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      
      if (newStatus == VideoRequestStatus.completed) {
        updates['completed_at'] = DateTime.now().toUtc().toIso8601String();
      }

      await SupabaseConfig.client
          .from('video_requests')
          .update(updates)
          .eq('id', requestId);

      // Refresh list and counts locally
      await fetchVideoRequestCounts();
      await fetchVideoRequests(page: _currentPage, searchQuery: _searchQuery);
      return true;
    } catch (e) {
      debugPrint('[VideoRequestProvider] Error updating video request status: $e');
      return false;
    }
  }

  /// Decline / Cancel a video request (updates status to cancelled with cancel reason and canceller user ID)
  Future<bool> cancelRequest(String requestId, {required String reason, String? cancelledByUserId}) async {
    try {
      final currentUserId = cancelledByUserId ?? SupabaseConfig.client.auth.currentUser?.id;
      final updates = <String, dynamic>{
        'status': VideoRequestStatus.cancelled.dbValue,
        'cancel_reason': reason,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      if (currentUserId != null && currentUserId.isNotEmpty) {
        updates['cancelled_by_user_id'] = currentUserId;
      }

      await SupabaseConfig.client
          .from('video_requests')
          .update(updates)
          .eq('id', requestId);

      // Refresh list and counts locally
      await fetchVideoRequestCounts();
      await fetchVideoRequests(page: _currentPage, searchQuery: _searchQuery);
      return true;
    } catch (e) {
      debugPrint('[VideoRequestProvider] Error declining video request: $e');
      return false;
    }
  }

  /// Delete request completely from table
  Future<bool> deleteRequest(String requestId) async {
    try {
      await SupabaseConfig.client
          .from('video_requests')
          .delete()
          .eq('id', requestId);

      // Refresh counts and list
      await fetchVideoRequestCounts();
      await fetchVideoRequests(page: _currentPage, searchQuery: _searchQuery);
      return true;
    } catch (e) {
      debugPrint('[VideoRequestProvider] Error deleting video request: $e');
      return false;
    }
  }

  RealtimeChannel? _realtimeChannel;

  /// Subscribe to realtime PostgreSQL changes on the video_requests table
  void subscribeToRealtimeChanges() {
    if (_realtimeChannel != null) return;

    _realtimeChannel = SupabaseConfig.client
        .channel('public:video_requests')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'video_requests',
          callback: (payload) {
            debugPrint('[VideoRequestProvider] Postgres change payload: $payload');
            
            final newRecord = payload.newRecord;
            final oldRecord = payload.oldRecord;
            final recordId = (newRecord['id'] ?? oldRecord['id'])?.toString();

            final bool isDeleted = (newRecord['is_deleted'] == true) ||
                (newRecord['is_deleted']?.toString().toLowerCase() == 'true') ||
                (payload.eventType == PostgresChangeEvent.delete);

            final bool isPresentOnCurrentPage = recordId != null &&
                _requests.any((r) => r.id == recordId);

            final approvalStatus = VideoRequestApprovalStatus.fromDbValue(
              (newRecord['admin_approval_status'] ?? oldRecord['admin_approval_status'])?.toString(),
            );

            // Re-fetch current page directly if record is deleted, updated on current page, approved, or inserted
            if (isDeleted ||
                isPresentOnCurrentPage ||
                approvalStatus == VideoRequestApprovalStatus.approved ||
                payload.eventType == PostgresChangeEvent.insert) {
              fetchVideoRequestCounts();
              fetchVideoRequests(page: _currentPage, searchQuery: _searchQuery);
            }
          },
        )
        .subscribe();
  }

  /// Fetch details for a single video request by ID (using joins)
  Future<VideoRequestModel?> fetchRequestById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from('video_requests')
          .select('''
            *,
            property:properties(
              *,
              address:addresses(*)
            ),
            broker:brokers(
              *,
              address:addresses(*)
            )
          ''')
          .eq('id', id)
          .single();

      return VideoRequestModel.fromJson(response);
    } catch (e) {
      debugPrint('[VideoRequestProvider] Error fetching request by ID: $e');
    }
    return null;
  }

  /// Upload property files to Supabase storage and call update_property_media RPC
  Future<bool> savePropertyMedia(
    String requestId,
    String propertyId,
    List<MediaModel> medias,
    ValueChanged<String> onProgress,
  ) async {
    try {
      final updatedMedias = <MediaModel>[];
      final totalMedias = medias.length;
      final bucketName = 'property_media';

      for (int i = 0; i < totalMedias; i++) {
        final media = medias[i];

        if (media.bytes != null) {
          onProgress("Uploading media ${i + 1} of $totalMedias...");

          final ext = media.type == 'video' ? 'mp4' : 'jpg';
          final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$i.$ext';
          final path = 'listings/$uniqueName';

          // Upload bytes to storage using centralized SupabaseStorageService
          final publicUrl = await SupabaseStorageService.uploadFile(
            filePath: path,
            bucketName: bucketName,
            customFileName: uniqueName,
            folderName: 'listings',
            fileBytes: media.bytes!,
          );

          String? thumbUrl;
          if (media.type == 'video') {
            Uint8List? thumbBytes = media.thumbnailBytes;
            if (thumbBytes != null) {
              onProgress("Uploading video thumbnail...");
              final thumbName = 'thumb_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
              thumbUrl = await SupabaseStorageService.uploadFile(
                filePath: thumbName,
                bucketName: bucketName,
                customFileName: thumbName,
                folderName: 'listings',
                fileBytes: thumbBytes,
              );
            }
          }

          updatedMedias.add(
            MediaModel(
              type: media.type,
              url: publicUrl,
              thumbnail: thumbUrl,
            ),
          );
        } else {
          // Existing media
          updatedMedias.add(media);
        }
      }

      // Convert updatedMedias list to json list
      final mediasJson = updatedMedias.map((m) => m.toJson()).toList();

      onProgress("Saving details to database...");
      // Call update_property_media RPC
      final response = await SupabaseConfig.client.rpc(
        'update_property_media',
        params: {
          'p_property_id': propertyId,
          'p_medias': mediasJson,
          'p_request_id': requestId,
        },
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response['success'] == true) {
          // Refresh provider counts & lists
          await fetchVideoRequestCounts();
          await fetchVideoRequests(page: _currentPage, searchQuery: _searchQuery);
          return true;
        } else {
          debugPrint('[VideoRequestProvider] DB save error: ${response['error']}');
        }
      }
    } catch (e) {
      debugPrint('[VideoRequestProvider] Error saving property media: $e');
    }
    return false;
  }

  void unsubscribeRealtime() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }

  void unsubscribeFromRealtimeChanges() => unsubscribeRealtime();

  void clear() {
    unsubscribeRealtime();
    _requests = [];
    _totalRequests = 0;
    _pendingRequests = 0;
    _inProgressRequests = 0;
    _completedRequests = 0;
    _cancelledRequests = 0;
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _hasMore = false;
    _searchQuery = '';
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeRealtime();
    super.dispose();
  }
}
