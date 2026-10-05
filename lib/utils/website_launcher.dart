import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens pages of the public C.Q.A.A.G website in the device's default browser.
///
/// The mobile app is for signed-in members only; visitors without an account
/// are sent to the website instead of browsing the app.
class WebsiteLauncher {
  WebsiteLauncher._();

  /// Base URL of the public website.
  static const String baseUrl = 'https://cqaaggh.org';

  /// Website home page.
  static const String home = '$baseUrl/';

  /// Website events page.
  static const String events = '$baseUrl/events/';

  /// Opens [url] in the device's default browser.
  ///
  /// Returns `true` if the browser was launched.
  static Future<bool> open([String url = home]) async {
    try {
      return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('WebsiteLauncher: could not open $url: $e');
      return false;
    }
  }
}
