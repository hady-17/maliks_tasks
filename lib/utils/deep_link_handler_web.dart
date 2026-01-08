import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkHandler {
  // On web, deep links are represented by the current URL. No stream is available.
  static void initialize() {
    // nothing to listen for on web
  }

  static Future<void> _handleDeepLink(Uri uri) async {
    try {
      if (uri.toString().contains('login-callback') ||
          uri.toString().contains('reset-password-callback') ||
          uri.toString().contains('signup-callback')) {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      }
    } catch (_) {
      // ignore errors during deep link handling in web
    }
  }

  /// Handle initial link on web using `Uri.base`.
  static Future<void> handleInitialLink() async {
    try {
      final uri = Uri.base;
      if (uri.toString().isNotEmpty) {
        await _handleDeepLink(uri);
      }
    } catch (_) {
      // ignore
    }
  }
}
