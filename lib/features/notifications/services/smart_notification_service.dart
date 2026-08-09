import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';

class SmartNotificationService {
  SmartNotificationService._();
  
  static final SmartNotificationService instance = SmartNotificationService._();

  /// Requests notification permission ONLY ONCE.
  /// If the user denies it, we track that denial and never prompt the system dialog again.
  Future<void> requestNotificationPermission(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool('notif_permission_asked') ?? false;

    if (alreadyAsked) return;

    final settings = await FirebaseMessaging.instance.requestPermission();

    await prefs.setBool('notif_permission_asked', true);

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      await prefs.setBool('notif_permission_denied', true);
    }
  }

  /// Checks if the user previously denied permissions.
  /// If they did, it shows a smart in-app reminder (SnackBar) offering them to open settings.
  /// Uses a 24-hour cooldown so the user is not spammed.
  Future<void> checkAndShowNotificationReminder(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final denied = prefs.getBool('notif_permission_denied') ?? false;

    if (!denied) return;

    final lastShown = prefs.getInt('last_notif_reminder') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // show only once per 24 hours (86400000 ms)
    if (now - lastShown < 86400000) return;

    await prefs.setInt('last_notif_reminder', now);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Enable notifications to get renewal alerts 🔔'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Enable',
          onPressed: () {
            AppSettings.openAppSettings(type: AppSettingsType.notification);
          },
        ),
      ),
    );
  }
}
