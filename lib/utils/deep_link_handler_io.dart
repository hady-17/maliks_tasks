import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkHandler {
  static final _appLinks = AppLinks();

  static void initialize() {
    // Listen for deep link events (when app is already running)
    _appLinks.uriLinkStream.listen((uri) async {
      await _handleDeepLink(uri);
    });
  }

  static Future<void> _handleDeepLink(Uri uri) async {
    try {
      if (uri.toString().contains('login-callback') ||
          uri.toString().contains('reset-password-callback') ||
          uri.toString().contains('signup-callback')) {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      }
    } catch (e) {
      // keep silent; don't crash the app due to deep link handling
    }
  }

  /// Call this when app starts to handle initial deep link (if app was closed)
  static Future<void> handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        await _handleDeepLink(uri);
      }
    } catch (e) {
      // ignore
    }
  }
}
