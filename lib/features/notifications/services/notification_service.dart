import 'local_notification_provider.dart';
import 'notification_permission_service.dart';
import 'notification_scheduler.dart';
import 'notification_settings_service.dart';
import 'notification_history_service.dart';
import '../models/notification_message.dart';
import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  late final LocalNotificationProvider provider;
  late final NotificationPermissionService permissionService;
  late final NotificationScheduler scheduler;
  late final NotificationSettingsService settingsService;

  Future<void> initialize() async {
    settingsService = NotificationSettingsService();
    await settingsService.initialize();

    provider = LocalNotificationProvider(settingsService: settingsService);
    await provider.initialize();
    
    permissionService = NotificationPermissionService();
    scheduler = NotificationScheduler(provider);
  }

  Future<void> sendTestNotification() async {
    final message = NotificationMessage(
      id: 'test_9999_${DateTime.now().millisecondsSinceEpoch}',
      title: '✅ Test Notification',
      description: 'Notifications are working perfectly!',
      timestamp: DateTime.now(),
      typeIcon: Icons.bug_report_rounded,
      iconColor: const Color(0xFF10B981),
    );
    NotificationHistoryService.instance.addNotification(message);

    await Future.delayed(const Duration(seconds: 2));
    await provider.showNotification(
      id: 9999,
      title: '✅ Test Notification',
      body: 'Notifications are working perfectly!',
      channelId: 'reminders_channel',
    );
  }
}
