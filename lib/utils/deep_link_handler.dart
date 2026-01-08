/// Conditional deep link handler facade.
/// Uses a web-specific implementation when running in the browser,
/// and a native implementation (using `app_links`) on other platforms.
export 'deep_link_handler_io.dart'
    if (dart.library.html) 'deep_link_handler_web.dart';
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
      // Handle authentication callbacks (email verification, password reset, etc.)
      if (uri.toString().contains('login-callback') ||
          uri.toString().contains('reset-password-callback') ||
          uri.toString().contains('signup-callback')) {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      }
    } catch (e) {
      print('Error handling deep link: $e');
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
      print('Error handling initial link: $e');
    }
  }
}
