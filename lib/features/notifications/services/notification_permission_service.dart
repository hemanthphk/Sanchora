import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class NotificationPermissionService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const String _permissionRequestedKey = 'has_requested_notification_permission';

  Future<bool> hasRequestedBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionRequestedKey) ?? false;
  }

  Future<bool> requestPermission() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await prefs.setBool(_permissionRequestedKey, true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await prefs.setBool(_permissionRequestedKey, true);
      return result ?? false;
    }
    return false;
  }
}
