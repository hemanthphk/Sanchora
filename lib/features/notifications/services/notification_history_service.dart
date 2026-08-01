import 'package:flutter/foundation.dart';
import '../models/notification_message.dart';

class NotificationHistoryService extends ChangeNotifier {
  NotificationHistoryService._internal();
  static final NotificationHistoryService instance = NotificationHistoryService._internal();

  final List<NotificationMessage> _notifications = [];

  List<NotificationMessage> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationMessage> get todayNotifications {
    final now = DateTime.now();
    return _notifications.where((n) => 
      n.timestamp.year == now.year && 
      n.timestamp.month == now.month && 
      n.timestamp.day == now.day
    ).toList();
  }

  List<NotificationMessage> get yesterdayNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _notifications.where((n) => 
      n.timestamp.year == yesterday.year && 
      n.timestamp.month == yesterday.month && 
      n.timestamp.day == yesterday.day
    ).toList();
  }

  List<NotificationMessage> get earlierNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final startOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
    return _notifications.where((n) => n.timestamp.isBefore(startOfYesterday)).toList();
  }

  void addNotification(NotificationMessage message) {
    _notifications.insert(0, message);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool updated = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        updated = true;
      }
    }
    if (updated) notifyListeners();
  }
}
