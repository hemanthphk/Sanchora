import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_settings_model.dart';
import 'notification_settings_service.dart';

class LocalNotificationProvider {
  final NotificationSettingsService settingsService;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  LocalNotificationProvider({required this.settingsService});

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    NotificationSettingsService.notificationTapStream.add(response.payload);
  }


  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'reminders_channel',
  }) async {
    final settings = settingsService.settings;
    final isPreviewHidden = settings.previewMode == NotificationPreviewMode.never;
    final finalTitle = isPreviewHidden ? 'Sanchora' : title;
    final finalBody = isPreviewHidden ? 'You have a new notification.' : body;

    await _plugin.show(
      id: id,
      title: finalTitle,
      body: finalBody,
      notificationDetails: _getDetails(channelId),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelId = 'reminders_channel',
  }) async {
    final settings = settingsService.settings;
    final isPreviewHidden = settings.previewMode == NotificationPreviewMode.never;
    final finalTitle = isPreviewHidden ? 'Sanchora' : title;
    final finalBody = isPreviewHidden ? 'You have a new notification.' : body;

    await _plugin.zonedSchedule(
      id: id,
      title: finalTitle,
      body: finalBody,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: _getDetails(channelId),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  NotificationDetails _getDetails(String baseChannelId) {
    final settings = settingsService.settings;
    
    // Dynamic channel ID to bypass Android's locked channel settings.
    final String dynamicChannelId = '${baseChannelId}_s${settings.playSound}_v${settings.enableVibration}';
    final String channelName = baseChannelId == 'reminders_channel' ? 'Reminders' : 'Summaries';
    final String channelDescription = baseChannelId == 'reminders_channel' 
        ? 'Notifications for subscription renewals and trials' 
        : 'Weekly and monthly summaries';
    final Importance importance = baseChannelId == 'reminders_channel' ? Importance.high : Importance.defaultImportance;
    final Priority priority = baseChannelId == 'reminders_channel' ? Priority.high : Priority.defaultPriority;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        dynamicChannelId,
        channelName,
        channelDescription: channelDescription,
        importance: importance,
        priority: priority,
        playSound: settings.playSound,
        enableVibration: settings.enableVibration,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: settings.playSound,
      ),
    );
  }
}
