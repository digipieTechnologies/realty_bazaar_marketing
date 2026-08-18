import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/toast/app_toast.dart';

class AppUtils {
  AppUtils._();

  /// Launches a URL using url_launcher, handling error states and showing error alerts.
  static Future<bool> launchAppUrl(String urlString) async {
    if (urlString.isEmpty) {
      AppToast.showError('Invalid Link', 'No URL link was provided.');
      return false;
    }

    final Uri url = Uri.parse(urlString.trim());
    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        return true;
      }
      throw Exception('System failed to launch browser.');
    } catch (e) {
      debugPrint('Error launching URL ($urlString): $e');
      AppToast.showError(
        'Launch Failed',
        'Could not open connection URL: ${e.toString()}',
      );
      return false;
    }
  }
}
