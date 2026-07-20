import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  runApp(const SanchoraApp());
}

class SanchoraApp extends StatelessWidget {
  const SanchoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanchora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}