import 'package:flutter/material.dart';

import 'package:sanchora/core/theme/app_theme.dart';
import 'package:sanchora/core/theme/theme_controller.dart';
import 'package:sanchora/features/splash/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sanchora/features/notifications/services/notification_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // In the future, we'll calculate dynamic weekly/monthly summaries here
    // and trigger a local notification.
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone for local notifications
  tz.initializeTimeZones();
  
  // Initialize Notifications
  await NotificationService.instance.initialize();
  
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

class SanchoraApp extends StatelessWidget {
  const SanchoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Sanchora',
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