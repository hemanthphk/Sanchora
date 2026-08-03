import 'package:flutter/material.dart';

import 'package:sanchora/core/theme/app_theme.dart';
import 'package:sanchora/core/theme/theme_controller.dart';
import 'package:sanchora/features/splash/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sanchora/features/notifications/services/notification_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sanchora/features/profile/services/profile_service.dart';
import 'package:sanchora/features/notifications/services/notification_settings_service.dart';
import 'package:sanchora/features/notifications/screens/notifications_inbox_screen.dart';
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // In the future, we'll calculate dynamic weekly/monthly summaries here
    // and trigger a local notification.
    return Future.value(true);
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone for local notifications
  tz.initializeTimeZones();
  
  // Initialize Notifications
  await NotificationService.instance.initialize();
  
  // Initialize Profile Service for avatars
  await ProfileService.initialize();
  
  // Initialize Workmanager
  Workmanager().initialize(
    callbackDispatcher,
  );
  
  // Schedule a weekly background task
  Workmanager().registerPeriodicTask(
    "weekly_summary",
    "weekly_summary_task",
    frequency: const Duration(days: 7),
    initialDelay: const Duration(hours: 24), // Will trigger roughly tomorrow, we can tweak for Sunday 9am later
  );
  
  await themeController.init();
  runApp(const SanchoraApp());
}

class SanchoraApp extends StatefulWidget {
  const SanchoraApp({super.key});

  @override
  State<SanchoraApp> createState() => _SanchoraAppState();
}

class _SanchoraAppState extends State<SanchoraApp> {
  @override
  void initState() {
    super.initState();
    NotificationSettingsService.notificationTapStream.stream.listen((payload) {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(builder: (context) => const NotificationsInboxScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Sanchora',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 200),
          themeAnimationCurve: Curves.easeOut,
          home: const SplashScreen(),
        );
      },
    );
  }
}