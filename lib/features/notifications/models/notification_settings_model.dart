enum NotificationPreviewMode {
  always,
  whenUnlocked,
  never,
}

extension NotificationPreviewModeExtension on NotificationPreviewMode {
  String get displayName {
    switch (this) {
      case NotificationPreviewMode.always:
        return 'Always';
      case NotificationPreviewMode.whenUnlocked:
        return 'When Unlocked';
      case NotificationPreviewMode.never:
        return 'Never';
    }
  }
}

class NotificationSettingsModel {
  final bool playSound;
  final bool enableVibration;
  final NotificationPreviewMode previewMode;

  const NotificationSettingsModel({
    this.playSound = true,
    this.enableVibration = true,
    this.previewMode = NotificationPreviewMode.always,
  });

  NotificationSettingsModel copyWith({
    bool? playSound,
    bool? enableVibration,
    NotificationPreviewMode? previewMode,
  }) {
    return NotificationSettingsModel(
      playSound: playSound ?? this.playSound,
      enableVibration: enableVibration ?? this.enableVibration,
      previewMode: previewMode ?? this.previewMode,
    );
  }
}
