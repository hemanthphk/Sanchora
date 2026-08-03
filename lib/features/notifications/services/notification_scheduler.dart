import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notification_provider.dart';

class NotificationScheduler {
  final LocalNotificationProvider _provider;

  NotificationScheduler(this._provider);

  // Settings keys
  static const String masterSwitchKey = 'notify_master_switch';
  static const String days7Key = 'notify_7_days';
  static const String days3Key = 'notify_3_days';
  static const String day1Key = 'notify_1_day';
  static const String renewalDayKey = 'notify_renewal_day';
  static const String quietHoursEnabledKey = 'notify_quiet_hours_enabled';
  static const String quietHoursStartKey = 'notify_quiet_hours_start'; // e.g. "22:00"
  static const String quietHoursEndKey = 'notify_quiet_hours_end';     // e.g. "07:00"

  Future<void> scheduleRemindersForSubscription(SubscriptionModel sub) async {
    final prefs = await SharedPreferences.getInstance();
    final masterEnabled = prefs.getBool(masterSwitchKey) ?? true;
    if (!masterEnabled || !sub.hasReminder) return;

    final baseId = sub.id.hashCode.abs();

    // Trial alert
    if (sub.isTrial) {

    } else {
      // Normal renewals
      if (prefs.getBool(days7Key) ?? false) {
        await _schedule(
          id: baseId + 7,
          title: '🔔 ${sub.name} renewal in 7 days',
          body: '₹${sub.currentPrice.toInt()} will be charged.',
          date: sub.nextRenewalDate.subtract(const Duration(days: 7)),
          prefs: prefs,
        );
      }
      if (prefs.getBool(days3Key) ?? false) {
        await _schedule(
          id: baseId + 3,
          title: '🔔 ${sub.name} renewal in 3 days',
          body: '₹${sub.currentPrice.toInt()} will be charged.',
          date: sub.nextRenewalDate.subtract(const Duration(days: 3)),
          prefs: prefs,
        );
      }
      if (prefs.getBool(day1Key) ?? true) {
        await _schedule(
          id: baseId + 1,
          title: '🔔 ${sub.name} renews tomorrow',
          body: '₹${sub.currentPrice.toInt()} will be charged.',
          date: sub.nextRenewalDate.subtract(const Duration(days: 1)),
          prefs: prefs,
        );
      }
      if (prefs.getBool(renewalDayKey) ?? false) {
        await _schedule(
          id: baseId,
          title: '🔔 ${sub.name} renews today',
          body: '₹${sub.currentPrice.toInt()} is being charged today.',
          date: sub.nextRenewalDate,
          prefs: prefs,
        );
      }
    }
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required SharedPreferences prefs,
  }) async {
    // We typically schedule for 9 AM
    DateTime scheduledDate = DateTime(date.year, date.month, date.day, 9, 0);

    // Apply quiet hours logic
    final quietHoursEnabled = prefs.getBool(quietHoursEnabledKey) ?? false;
    if (quietHoursEnabled) {
      final startStr = prefs.getString(quietHoursStartKey) ?? "22:00";
      final endStr = prefs.getString(quietHoursEndKey) ?? "07:00";
      final startParts = startStr.split(':');
      final endParts = endStr.split(':');
      final startHour = int.parse(startParts[0]);
      final startMin = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMin = int.parse(endParts[1]);

      final schedTime = scheduledDate.hour * 60 + scheduledDate.minute;
      final startTime = startHour * 60 + startMin;
      final endTime = endHour * 60 + endMin;

      bool inQuietHours = false;
      if (startTime < endTime) {
        inQuietHours = schedTime >= startTime && schedTime < endTime;
      } else {
        // Crosses midnight
        inQuietHours = schedTime >= startTime || schedTime < endTime;
      }

      if (inQuietHours) {
        // Shift to end time
        scheduledDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, endHour, endMin);
      }
    }

    if (scheduledDate.isAfter(DateTime.now())) {
      await _provider.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );
    }
  }

  Future<void> cancelReminders(String subscriptionId) async {
    final baseId = subscriptionId.hashCode.abs();
    await _provider.cancelNotification(baseId);
    await _provider.cancelNotification(baseId + 1);
    await _provider.cancelNotification(baseId + 3);
    await _provider.cancelNotification(baseId + 7);
    await _provider.cancelNotification(baseId + 10);
  }

  Future<void> rescheduleAll(List<SubscriptionModel> subscriptions) async {
    await _provider.cancelAllNotifications();
    for (final sub in subscriptions) {
      await scheduleRemindersForSubscription(sub);
    }
  }
}
