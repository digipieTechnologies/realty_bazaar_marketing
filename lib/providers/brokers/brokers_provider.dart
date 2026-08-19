// File: lib/providers/brokers/brokers_provider.dart
// Purpose: Manage state and Supabase client RPC calls for the brokers registry tab in realty_marketing.

import 'package:flutter/material.dart';
import '../../core/supabase/supabase_config.dart';
import '../../models/models.dart';

class BrokersProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<UserModel> _brokers = [];
  List<UserModel> get brokers => _brokers;

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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetch paginated brokers list using fetch_brokers RPC
  Future<void> fetchBrokers({
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
        'fetch_brokers',
        params: {
          'p_search_query': searchQuery.isEmpty ? null : searchQuery.trim(),
          'p_page': page,
          'p_limit': _itemsPerPage,
        },
      );

      if (response != null) {
        final Map<String, dynamic> resMap = response is Map<String, dynamic>
            ? response
            : {};

        if (resMap['success'] == true && resMap['data'] is List) {
          final rawList = resMap['data'] as List;
          _brokers = rawList
              .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
              .toList();

          final pagination = resMap['pagination'] as Map<String, dynamic>? ?? {};
          _totalItems = int.tryParse(pagination['total_items']?.toString() ?? '0') ?? _brokers.length;
          _totalPages = int.tryParse(pagination['total_pages']?.toString() ?? '1') ?? 1;
          _hasMore = pagination['has_more'] as bool? ?? false;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
          return;
        }
      }
      _errorMessage = 'Failed to fetch brokers.';
    } catch (e) {
      debugPrint('[BrokersProvider] Error calling fetch_brokers RPC: $e');
      _errorMessage = e.toString();
    }

    _brokers = [];
    _totalItems = 0;
    _totalPages = 1;
    _hasMore = false;
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _brokers = [];
    _totalItems = 0;
    _totalPages = 1;
    _hasMore = false;
    _currentPage = 1;
    _searchQuery = '';
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
