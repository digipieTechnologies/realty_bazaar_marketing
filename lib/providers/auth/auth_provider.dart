import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/notification_service.dart';
import '../../core/supabase/supabase_config.dart';
import '../../util/common_ext.dart';
import '../../models/models.dart';
import '../../widgets/toast/app_toast.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../brokers/brokers_provider.dart';
import '../video_request/video_request_provider.dart';
import '../chat/chat_provider.dart';

class AuthProvider extends ChangeNotifier {
  static const String sessionKey = 'user_id';
  final _storage = GetStorage();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears any lingering authentication error message state.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Signs in a user using email and password, then saves the session.
  /// Returns true if successful, false otherwise.
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Authentication failed. No user returned.');
      }

      // Verify user state in public.users table
      final profile = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        await signOut();
        throw const AuthException('User profile not found in public registry.');
      }

      final isActive = profile['is_active'] as bool? ?? true;
      final isDeleted = profile['is_deleted'] as bool? ?? false;

      if (isDeleted) {
        await signOut();
        throw const AuthException('This account has been deleted.');
      }
      if (!isActive) {
        await signOut();
        throw const AuthException('This account is currently deactivated.');
      }

      // Verify Role Access: Only UserRole.marketing accounts are allowed in this portal
      final userRole = UserRole.fromDbValue(profile['role']);
      if (userRole != UserRole.marketing) {
        await signOut();
        throw const AuthException(
          'Access Denied: Only Marketing/Ads accounts can sign in to this portal.',
        );
      }

      // Persist user session ID
      await _storage.write(sessionKey, user.id);

      // Fetch and cache user profile
      _userProfile = UserModel.fromJson(profile);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.getUserExceptionMessage());
      _setLoading(false);
      return false;
    }
  }

  /// Verifies email OTP and updates is_email_verified flag in public.users table.
  /// Verifies email OTP via server-side DB query matching and updates is_email_verified flag in public.users table.
  Future<bool> verifyEmailOtp({
    String? email,
    String? userId,
    required String otp,
    AppOtpType otpType = AppOtpType.emailVerify,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final targetUserId = userId ?? _userProfile?.id;
      final targetEmail = email ?? _userProfile?.email;

      if (targetUserId == null && targetEmail == null) {
        throw const AuthException('No user session or email specified for OTP verification.');
      }

      debugPrint('🔍 [Frontend Log] Verifying OTP: email=$targetEmail, userId=$targetUserId, otp=$otp, type=${otpType.dbValue}');

      // Server-Side Verification: Query user_otps directly matching email/userId, otp, otp_type & non-expired time
      final nowIso = DateTime.now().toUtc().toIso8601String();
      var query = SupabaseConfig.client
          .from('user_otps')
          .select()
          .eq('otp', otp.trim())
          .eq('otp_type', otpType.dbValue)
          .gte('expiry_at', nowIso);

      if (targetEmail != null && targetEmail.trim().isNotEmpty) {
        query = query.eq('email', targetEmail.trim().toLowerCase());
      } else if (targetUserId != null) {
        query = query.eq('user_id', targetUserId);
      }

      final otpRecords = await query;
      debugPrint('✅ [Frontend Log] OTP Verification records found: ${otpRecords.length}');

      if (otpRecords.isEmpty) {
        throw const AuthException('Invalid or expired verification code. Please check and try again.');
      }

      final record = otpRecords.first;

      // Update is_email_verified to true in public.users table
      if (targetUserId != null) {
        await SupabaseConfig.client
            .from('users')
            .update({'is_email_verified': true})
            .eq('id', targetUserId);
      }
      if (targetEmail != null && targetEmail.trim().isNotEmpty) {
        await SupabaseConfig.client
            .from('users')
            .update({'is_email_verified': true})
            .eq('email', targetEmail.trim().toLowerCase());
      }

      // Clean up used OTP record
      await SupabaseConfig.client
          .from('user_otps')
          .delete()
          .eq('id', record['id']);

      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(isEmailVerified: true);
      } else if (targetUserId != null) {
        await fetchCurrentUserProfile(targetUserId);
      }

      debugPrint('🎉 [Frontend Log] Email OTP verified successfully.');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ [Frontend Log] verifyEmailOtp Error: $e');
      _setError(e.getUserExceptionMessage());
      _setLoading(false);
      return false;
    }
  }

  /// Resends a new OTP using `generate_user_otp` RPC function.
  Future<bool> resendEmailOtp({
    String? email,
    String? userId,
    AppOtpType otpType = AppOtpType.emailVerify,
  }) async {
    _setError(null);
    try {
      final targetEmail = email ?? _userProfile?.email;
      if (targetEmail == null) {
        throw const AuthException('Email address is required to resend OTP.');
      }

      debugPrint('🔑 [Frontend Log] Resending OTP for email: $targetEmail, type: ${otpType.dbValue}');

      // Call generate_user_otp RPC function
      final res = await SupabaseConfig.client.rpc('generate_user_otp', params: {
        'p_email': targetEmail,
        'p_otp_type': otpType.dbValue,
      });

      debugPrint('✅ [Frontend Log] Resend generate_user_otp RPC Response: $res');

      return true;
    } catch (e) {
      debugPrint('❌ [Frontend Log] resendEmailOtp Error: $e');
      _setError(e.getUserExceptionMessage());
      return false;
    }
  }



  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;

  /// Fetches the currently logged-in user profile, performing active session checks, role access validation, and auto sign-out if deactivated/deleted.
  Future<UserModel?> fetchCurrentUserProfile(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select('*, broker_id(*, address_id(*))')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        _userProfile = null;
        notifyListeners();
        await signOut();
        AppRoutes.router.go(AppRoutes.login);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppToast.showError('Session Expired', 'User account not found on server.');
        });
        return null;
      }

      final profile = UserModel.fromJson(response);

      // Check soft-delete status
      if (profile.isDeleted ?? false) {
        _userProfile = null;
        notifyListeners();
        await signOut();
        AppRoutes.router.go(AppRoutes.login);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppToast.showError('Auth Error', 'This account has been deleted.');
        });
        return null;
      }

      // Check active status
      if (!(profile.isActive ?? true)) {
        _userProfile = null;
        notifyListeners();
        await signOut();
        AppRoutes.router.go(AppRoutes.login);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppToast.showError('Auth Error', 'This account is currently deactivated.');
        });
        return null;
      }

      // Check email verification status
      if (!(profile.isEmailVerified ?? false)) {
        _userProfile = null;
        notifyListeners();
        await signOut();
        AppRoutes.router.go(AppRoutes.login);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppToast.showError(
            'Email Verification Required',
            'Your email address is not verified. Please sign in to verify your email.',
          );
        });
        return null;
      }

      // Verify Role Access: Only Marketing/Ads accounts allowed in this portal
      if (profile.role != UserRole.marketing) {
        _userProfile = null;
        notifyListeners();
        await signOut();
        AppRoutes.router.go(AppRoutes.login);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppToast.showError('Access Denied', 'Only Marketing/Ads accounts can sign in to this portal.');
        });
        return null;
      }

      _userProfile = profile;
      notifyListeners();
      subscribeToCurrentUserRealtime(id);
      syncDeviceToken(id);
      return _userProfile;
    } catch (e) {
      debugPrint('Error fetching current user profile for $id: $e');
      return null;
    }
  }

  RealtimeChannel? _userRealtimeChannel;

  /// Subscribes to realtime updates for the current logged-in user in public.users
  void subscribeToCurrentUserRealtime(String userId) {
    unsubscribeCurrentUserRealtime();

    _userRealtimeChannel = SupabaseConfig.client
        .channel('user_realtime_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) async {
            final newRecord = payload.newRecord;
            if (newRecord.isEmpty) return;

            final updatedUser = UserModel.fromJson(newRecord);

            if (updatedUser.isDeleted ?? false) {
              await _handleRemoteLogout('Auth Error', 'This account has been deleted.');
            } else if (!(updatedUser.isActive ?? true)) {
              await _handleRemoteLogout('Auth Error', 'This account is currently deactivated.');
            } else if (!(updatedUser.isEmailVerified ?? false)) {
              await _handleRemoteLogout('Email Verification Required', 'Your email verification status was modified. Please sign in again.');
            } else if (updatedUser.role != UserRole.marketing) {
              await _handleRemoteLogout('Access Denied', 'Your user role has been modified.');
            }
          },
        )
        .subscribe();
  }

  Future<void> _handleRemoteLogout(String title, String message) async {
    unsubscribeCurrentUserRealtime();
    _userProfile = null;
    notifyListeners();
    await signOut();
    AppRoutes.router.go(AppRoutes.login);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppToast.showError(title, message);
    });
  }

  void unsubscribeCurrentUserRealtime() {
    if (_userRealtimeChannel != null) {
      SupabaseConfig.client.removeChannel(_userRealtimeChannel!);
      _userRealtimeChannel = null;
    }
  }

  /// Pure query helper to fetch any user details by UUID without triggering auth session side-effects or logouts.
  Future<UserModel?> getUserById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select('*, broker_id(*, address_id(*))')
          .eq('id', id)
          .maybeSingle();
      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile by ID $id: $e');
      return null;
    }
  }

  /// Checks email existence and role, then generates a 2-minute OTP for forgot password using `generate_user_otp` RPC.
  Future<bool> requestForgotPasswordOtp(String email, {UserRole expectedRole = UserRole.marketing}) async {
    _setLoading(true);
    _setError(null);
    try {
      final cleanEmail = email.trim().toLowerCase();

      // 1. Check if email exists in public.users
      final userRecord = await SupabaseConfig.client
          .from('users')
          .select('id, role')
          .eq('email', cleanEmail)
          .maybeSingle();

      if (userRecord == null) {
        throw const AuthException('No registered account found with this email address.');
      }

      final roleStr = userRecord['role'] as String?;
      if (roleStr != expectedRole.dbValue) {
        throw const AuthException('This account does not have permission for this portal.');
      }

      // 2. Invoke generate_user_otp RPC for forgot_password type
      final res = await SupabaseConfig.client.rpc('generate_user_otp', params: {
        'p_email': cleanEmail,
        'p_otp_type': AppOtpType.forgotPassword.dbValue,
      });

      debugPrint('✅ [Frontend Log] requestForgotPasswordOtp RPC Response: $res');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ [Frontend Log] requestForgotPasswordOtp Error: $e');
      _setError(e.getUserExceptionMessage());
      _setLoading(false);
      return false;
    }
  }

  /// Updates user password in backend database via reset_user_password RPC.
  Future<bool> resetPasswordWithOtp({required String email, required String newPassword}) async {
    _setLoading(true);
    _setError(null);
    try {
      final cleanEmail = email.trim().toLowerCase();
      final res = await SupabaseConfig.client.rpc('reset_user_password', params: {
        'p_email': cleanEmail,
        'p_new_password': newPassword,
      });

      debugPrint('✅ [Frontend Log] resetPasswordWithOtp Response: $res');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ [Frontend Log] resetPasswordWithOtp Error: $e');
      _setError(e.getUserExceptionMessage());
      _setLoading(false);
      return false;
    }
  }

  static const String fcmTokenKey = 'cached_fcm_token';

  /// Syncs logged in user session with OneSignal push service.
  Future<void> syncDeviceToken(String userId) async {
    try {
      await NotificationService.instance.bindUserToOneSignal(userId);
    } catch (e) {
      debugPrint('Error syncing OneSignal user ID: $e');
    }
  }

  /// Unbinds user from OneSignal upon user sign out.
  Future<void> removeDeviceTokenOnLogout() async {
    try {
      await NotificationService.instance.unbindUserFromOneSignal();
    } catch (e) {
      debugPrint('Error removing device token on logout: $e');
    }
  }

  /// Logs out the user and clears all data, subscriptions, and push token sessions ONLY after successful sign out.
  Future<void> signOut([BuildContext? context]) async {
    _setLoading(true);
    try {
      // 1. First, attempt to sign out from Supabase Auth backend
      await SupabaseConfig.client.auth.signOut();

      // 2. Unsubscribe user profile real-time listener
      unsubscribeCurrentUserRealtime();

      // 3. Remove all active Supabase real-time channel subscriptions
      try {
        await SupabaseConfig.client.removeAllChannels();
      } catch (e) {
        debugPrint('Error removing channels on sign out: $e');
      }

      // 4. Unbind user session from OneSignal push notification service
      await removeDeviceTokenOnLogout();

      // 5. Remove persisted session key from storage
      await _storage.remove(sessionKey);

      // 6. Clear cached user profile and error state
      _userProfile = null;
      _errorMessage = null;

      // 7. Reset all feature provider in-memory data AFTER successful sign out
      final targetContext = context ?? AppRoutes.rootNavigatorKey.currentContext;
      if (targetContext != null && targetContext.mounted) {
        try {
          targetContext.read<BrokersProvider>().clear();
          targetContext.read<VideoRequestProvider>().clear();
          targetContext.read<ChatProvider>().clear();
        } catch (e) {
          debugPrint('Error clearing feature providers on sign out: $e');
        }
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
}
