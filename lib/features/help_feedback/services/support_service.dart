import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SupportService {
  SupportService._internal();
  static final SupportService instance = SupportService._internal();

  final String _supportEmail = 'sanchora.team@gmail.com';

  Future<Map<String, String>> getSystemInfo() async {
    String appVersion = 'Unknown';
    String deviceModel = 'Unknown';
    String osVersion = 'Unknown';

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      debugPrint('Failed to get package info: $e');
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        osVersion = 'iOS ${iosInfo.systemVersion}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceModel = 'Windows PC';
        osVersion = 'Windows ${windowsInfo.majorVersion}.${windowsInfo.minorVersion}';
      }
    } catch (e) {
      debugPrint('Failed to get device info: $e');
      if (Platform.isAndroid) {
        osVersion = 'Android';
      } else if (Platform.isIOS) {
        osVersion = 'iOS';
      }
    }

    return {
      'appVersion': appVersion,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String _formatSystemInfo(Map<String, String> info) {
    return '''

---
System Information:
App Version: ${info['appVersion']}
Device Model: ${info['deviceModel']}
OS Version: ${info['osVersion']}
Timestamp: ${info['timestamp']}
''';
  }

  Future<bool> launchEmail({
    required String subject,
    required String body,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    // Dart's Uri.queryParameters encodes spaces as '+' per x-www-form-urlencoded.
    // However, the mailto: scheme requires spaces to be percent-encoded as '%20'.
    // Literal '+' characters are safely encoded as '%2B' before this replacement.
    final String properlyEncodedUrl = emailLaunchUri.toString().replaceAll('+', '%20');
    final Uri parsedUri = Uri.parse(properlyEncodedUrl);

    debugPrint('Launching URI: $parsedUri');

    try {
      final launched = await launchUrl(
        parsedUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        return true;
      } else {
        debugPrint('launchUrl returned false for $parsedUri');
        return false;
      }
    } catch (e) {
      debugPrint('Exception launching email URI: $e');
      return false;
    }
  }

  Future<bool> contactSupport() async {
    final info = await getSystemInfo();
    final body = _formatSystemInfo(info);
    
    return await launchEmail(
      subject: 'Sanchora Support',
      body: 'Hi Sanchora Team,\n\n[Please describe your issue here]\n$body',
    );
  }

  Future<bool> sendFeedback({
    required String feedbackType,
    required String description,
  }) async {
    final info = await getSystemInfo();
    final systemInfoFormatted = _formatSystemInfo(info);
    
    final body = '''
Feedback Type: $feedbackType

Description:
$description
$systemInfoFormatted
''';

    return await launchEmail(
      subject: 'Sanchora Feedback',
      body: body,
    );
  }

  Future<bool> reportBug({
    required String bugTitle,
    required String description,
    String? screenshotPath,
  }) async {
    final info = await getSystemInfo();
    final systemInfoFormatted = _formatSystemInfo(info);
    
    final body = '''
Bug Title: $bugTitle

Description:
$description

(Screenshot attached manually if applicable)
$systemInfoFormatted
''';

    // Note: mailto scheme doesn't universally support attachments. 
    // In a future backend integration, the screenshotPath will be uploaded to a server.
    return await launchEmail(
      subject: 'Sanchora Bug Report',
      body: body,
    );
  }
}
