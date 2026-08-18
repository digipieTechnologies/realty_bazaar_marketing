// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../app/app_assets.dart';
import '../../../widgets/brand/app_logo.dart';
import '../../../core/localization/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _logoFadeAnimation;
  late AnimationController _marketingTagsController;
  late Animation<double> _tagsFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Logo and main title fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // 2. Marketing tags secondary delayed fade-in
    _marketingTagsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _tagsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _marketingTagsController,
      curve: Curves.easeIn,
    ));

    // Start fade animations sequentially
    _fadeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _marketingTagsController.forward();
        }
      });
    });

    // 3. Route check after 3.5 seconds total
    Timer(const Duration(milliseconds: 3500), _checkSessionAndRoute);
  }

  void _checkSessionAndRoute() {
    if (!mounted) return;

    final userId = GetStorage().read<String>('user_id');
    if (userId != null && userId.isNotEmpty) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _marketingTagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary, // Slate 900
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Building Banner backdrop at the bottom
            Positioned.fill(
              child: Opacity(
                opacity: 0.20,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppAssets.building),
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Branding & Marketing Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glassmorphic logo container
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1.5,
                          ),
                        ),
                        child: const AppLogo(
                          size: 64.0,
                          backgroundColor: Colors.transparent,
                          iconColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const Text(
                        'BrokerHive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        context.tr('brokerflow_marketing').toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary, // Indigo accent
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        context.tr('real_estate_growth_platform'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48.0),

                // 3. Marketing Essence Taglines (delayed entry)
                FadeTransition(
                  opacity: _tagsFadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        context.tr('marketing_splash_tag'),
                        style: const TextStyle(
                          color: AppColors.secondary, // Teal accent
                          fontSize: 12.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      // Horizontal list of marketing focus badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _marketingBadge("AD CONVERSIONS"),
                          const SizedBox(width: 8),
                          _marketingBadge("LEAD CAPTURE"),
                          const SizedBox(width: 8),
                          _marketingBadge("ROI METRICS"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _marketingBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
