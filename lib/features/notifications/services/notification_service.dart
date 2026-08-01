import 'local_notification_provider.dart';
import 'notification_permission_service.dart';
import 'notification_scheduler.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  late final LocalNotificationProvider provider;
  late final NotificationPermissionService permissionService;
  late final NotificationScheduler scheduler;

  Future<void> initialize() async {
    provider = LocalNotificationProvider();
    await provider.initialize();
    
    permissionService = NotificationPermissionService();
    scheduler = NotificationScheduler(provider);
  }

  Future<void> sendTestNotification() async {
    await provider.showNotification(
      id: 9999,
      title: '✅ Test Notification',
      body: 'Notifications are working perfectly!',
    );
  }
}
