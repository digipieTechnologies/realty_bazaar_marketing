// File: lib/main.dart
// Purpose: Application entry point, service initialization, and routing setup for the marketing portal.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'app/app_strings.dart';
import 'providers/auth/auth_provider.dart';
import 'providers/language/language_provider.dart';
import 'providers/video_request/video_request_provider.dart';
import 'providers/chat/chat_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'providers/brokers/brokers_provider.dart';

void main() async {
  // Remove hash (#) from web url routing
  usePathUrlStrategy();

  // Ensure Flutter engine bindings are loaded
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal Notification Service
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('NotificationService initialization error: $e');
  }

  // Lock device orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 1. Read Supabase credentials from compile-time environment defines
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // 2. Initialize Supabase
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      // ignore: deprecated_member_use
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      debugPrint('Supabase initialized successfully!');
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
    }
  } else {
    debugPrint(
      'Supabase credentials missing or invalid in environment defines',
    );
  }

  // 3. Initialize storage service via GetX Dependency Injection
  try {
    await Get.putAsync(() => StorageService().init());
    debugPrint('StorageService initialized successfully!');
  } catch (e) {
    debugPrint('Failed to initialize StorageService: $e');
  }

  // 4. Initialize NotificationService
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Failed to initialize NotificationService: $e');
  }

  // 5. Run the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => VideoRequestProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => BrokersProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp.router(
            title: AppStrings.appName,
            theme: AppTheme.lightTheme,
            routerConfig: AppRoutes.router,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
              Locale('gu', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
