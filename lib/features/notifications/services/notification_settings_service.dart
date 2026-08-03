import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_settings_model.dart';

class NotificationSettingsService {
  static final StreamController<String?> notificationTapStream = StreamController<String?>.broadcast();
  static const String _keyPlaySound = 'notification_play_sound';
  static const String _keyEnableVibration = 'notification_enable_vibration';
  static const String _keyPreviewMode = 'notification_preview_mode';

  late final SharedPreferences _prefs;
  NotificationSettingsModel _settings = const NotificationSettingsModel();

  NotificationSettingsModel get settings => _settings;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    final playSound = _prefs.getBool(_keyPlaySound) ?? true;
    final enableVibration = _prefs.getBool(_keyEnableVibration) ?? true;
    final previewModeIndex = _prefs.getInt(_keyPreviewMode) ?? 0;
    
    final previewMode = NotificationPreviewMode.values.length > previewModeIndex 
        ? NotificationPreviewMode.values[previewModeIndex]
        : NotificationPreviewMode.always;

    _settings = NotificationSettingsModel(
      playSound: playSound,
      enableVibration: enableVibration,
      previewMode: previewMode,
    );
  }

  Future<void> updateSettings(NotificationSettingsModel newSettings) async {
    _settings = newSettings;
    await _prefs.setBool(_keyPlaySound, newSettings.playSound);
    await _prefs.setBool(_keyEnableVibration, newSettings.enableVibration);
    await _prefs.setInt(_keyPreviewMode, newSettings.previewMode.index);
  }
}
