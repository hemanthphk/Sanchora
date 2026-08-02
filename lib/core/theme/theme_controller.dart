import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeModeKey = 'themeModeString';
  static const String _legacyThemeKey = 'isDarkMode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeModeKey);
    
    if (modeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == modeString,
        orElse: () => ThemeMode.system,
      );
    } else {
      final isDark = prefs.getBool(_legacyThemeKey);
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        await prefs.setString(_themeModeKey, _themeMode.name);
      } else {
        _themeMode = ThemeMode.system;
      }
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    await prefs.setBool(_legacyThemeKey, mode == ThemeMode.dark);
  }

  Future<void> toggleTheme() async {
    setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

// Global singleton instance for the lightest state management
final themeController = ThemeController();
