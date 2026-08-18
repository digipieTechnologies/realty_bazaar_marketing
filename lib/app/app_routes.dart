// File: lib/app/app_routes.dart
// Purpose: Routing table and GoRouter configuration with Navigator keys for the marketing portal.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_storage/get_storage.dart';
import '../modules/auth/screens/login_screen.dart';
import '../modules/auth/screens/otp_verification_screen.dart';
import '../modules/auth/screens/splash_screen.dart';
import '../modules/dashboard/screens/shell_layout_screen.dart';
import '../modules/dashboard/screens/dashboard_tab_screen.dart';
import '../modules/dashboard/screens/brokers_tab_screen.dart';
import '../modules/dashboard/screens/video_requests_tab_screen.dart';
import '../modules/dashboard/screens/profile_tab_screen.dart';
import '../modules/dashboard/screens/video_request_details_screen.dart';

import '../modules/auth/screens/reset_password_screen.dart';
import '../models/otp_type.dart';

class AppRoutes {
  AppRoutes._();

  // Global Navigator Key for AppOverlay/Toasts access
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  // Route Paths
  static const String initial = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String home = '/dashboard';

  // GoRouter Singleton Instance
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initial,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final userId = GetStorage().read<String>('user_id');
      final isLoggedIn = userId != null && userId.isNotEmpty;

      final goingToAuth =
          state.matchedLocation == login ||
          state.matchedLocation == forgotPassword ||
          state.matchedLocation == verifyOtp ||
          state.matchedLocation == resetPassword;

      final goingToSplash = state.matchedLocation == initial;

      final goingToLoginOrForgotPassword =
          state.matchedLocation == login ||
          state.matchedLocation == forgotPassword;

      if (!isLoggedIn && !goingToAuth && !goingToSplash) {
        return login;
      }

      if (isLoggedIn && goingToLoginOrForgotPassword) {
        return home;
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Route not found: ${state.uri.path}',
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: initial,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(initialMode: AuthMode.login),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgot_password',
        builder: (context, state) => const LoginScreen(initialMode: AuthMode.forgotPassword),
      ),
      GoRoute(
        path: verifyOtp,
        name: 'verify_otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String?;
          final userId = extra?['userId'] as String?;
          final otpType = extra?['otpType'] as AppOtpType? ?? AppOtpType.emailVerify;
          return OtpVerificationScreen(email: email, userId: userId, otpType: otpType);
        },
      ),
      GoRoute(
        path: resetPassword,
        name: 'reset_password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => ShellLayoutScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardTabScreen(),
          ),
          GoRoute(
            path: '/brokers',
            name: 'brokers',
            builder: (context, state) => const BrokersTabScreen(),
          ),
          GoRoute(
            path: '/video-requests',
            name: 'video_requests',
            builder: (context, state) => const VideoRequestsTabScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileTabScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/video-request-details/:id',
        name: 'video_request_details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VideoRequestDetailsScreen(requestId: id);
        },
      ),
    ],
  );
}
