import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationProvider {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

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
    await _plugin.initialize(settings: initSettings);
    
    await _createAndroidChannels();
  }

  Future<void> _createAndroidChannels() async {
    final flutterLocalNotificationsPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (flutterLocalNotificationsPlugin == null) return;

    const AndroidNotificationChannel remindersChannel = AndroidNotificationChannel(
      'reminders_channel',
      'Reminders',
      description: 'Notifications for subscription renewals and trials',
      importance: Importance.high,
    );
    const AndroidNotificationChannel summariesChannel = AndroidNotificationChannel(
      'summaries_channel',
      'Summaries',
      description: 'Weekly and monthly summaries',
      importance: Importance.defaultImportance,
    );

    await flutterLocalNotificationsPlugin.createNotificationChannel(remindersChannel);
    await flutterLocalNotificationsPlugin.createNotificationChannel(summariesChannel);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'reminders_channel',
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
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
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
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

  NotificationDetails _getDetails(String channelId) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId == 'reminders_channel' ? 'Reminders' : 'Summaries',
        importance: channelId == 'reminders_channel' ? Importance.high : Importance.defaultImportance,
        priority: channelId == 'reminders_channel' ? Priority.high : Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }
}
