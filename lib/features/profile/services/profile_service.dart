import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  const ProfileService();

  static const String _avatarKey = 'profile_avatar_path';

  /// Global notifier for the avatar path
  static final ValueNotifier<String?> avatarPathNotifier = ValueNotifier(null);

  /// Load the saved avatar path and verify the file exists
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_avatarKey);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          avatarPathNotifier.value = path;
        } else {
          // File was deleted outside the app, clear the pref
          await prefs.remove(_avatarKey);
          avatarPathNotifier.value = null;
        }
      }
    } catch (e) {
      debugPrint('Error initializing avatar: $e');
    }
  }

  /// Save a new avatar path
  static Future<void> saveAvatarPath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarKey, path);
      avatarPathNotifier.value = path;
    } catch (e) {
      debugPrint('Error saving avatar path: $e');
      rethrow;
    }
  }

  /// Remove the current avatar
  static Future<void> removeAvatar() async {
    try {
      final currentPath = avatarPathNotifier.value;
      if (currentPath != null) {
        final file = File(currentPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_avatarKey);
      avatarPathNotifier.value = null;
    } catch (e) {
      debugPrint('Error removing avatar: $e');
      rethrow;
    }
  }
}
