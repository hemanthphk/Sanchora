import 'package:flutter/material.dart';

import 'package:sanchora/core/theme/app_theme.dart';
import 'package:sanchora/core/theme/theme_controller.dart';
import 'package:sanchora/features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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