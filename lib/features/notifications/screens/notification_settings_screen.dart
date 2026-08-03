import 'package:flutter/material.dart';
import 'package:sanchora/features/profile/widgets/settings_section.dart';
import 'package:sanchora/features/profile/widgets/settings_tile.dart';
import 'package:sanchora/features/notifications/services/notification_scheduler.dart';
import 'package:sanchora/features/notifications/services/notification_service.dart';
import 'package:sanchora/features/notifications/models/notification_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanchora/core/widgets/sanchora_page_header.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late SharedPreferences _prefs;
  bool _isLoading = true;

  bool _masterSwitch = true;
  bool _notify7Days = false;
  bool _notify3Days = false;
  bool _notify1Day = true;
  bool _notifyRenewalDay = false;
  bool _notifyWeekly = true;
  bool _notifyMonthly = true;
  bool _quietHoursEnabled = false;
  
  String _quietStart = "22:00";
  String _quietEnd = "07:00";

  late NotificationSettingsModel _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _settings = NotificationService.instance.settingsService.settings;

    setState(() {
      _masterSwitch = _prefs.getBool(NotificationScheduler.masterSwitchKey) ?? true;
      _notify7Days = _prefs.getBool(NotificationScheduler.days7Key) ?? false;
      _notify3Days = _prefs.getBool(NotificationScheduler.days3Key) ?? false;
      _notify1Day = _prefs.getBool(NotificationScheduler.day1Key) ?? true;
      _notifyRenewalDay = _prefs.getBool(NotificationScheduler.renewalDayKey) ?? false;
      _notifyWeekly = _prefs.getBool('notify_weekly_summary') ?? true;
      _notifyMonthly = _prefs.getBool('notify_monthly_summary') ?? true;
      _quietHoursEnabled = _prefs.getBool(NotificationScheduler.quietHoursEnabledKey) ?? false;
      _quietStart = _prefs.getString(NotificationScheduler.quietHoursStartKey) ?? "22:00";
      _quietEnd = _prefs.getString(NotificationScheduler.quietHoursEndKey) ?? "07:00";
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    await _prefs.setBool(key, value);
    _loadSettings();
  }

  Future<void> _updateNotificationSettings(NotificationSettingsModel newSettings) async {
    await NotificationService.instance.settingsService.updateSettings(newSettings);
    setState(() {
      _settings = newSettings;
    });
  }

  void _showPreviewModeSelector() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Notification Preview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...NotificationPreviewMode.values.map((mode) {
                  final isSelected = _settings.previewMode == mode;
                  return InkWell(
                    onTap: () {
                      _updateNotificationSettings(_settings.copyWith(previewMode: mode));
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              mode.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const SanchoraPageHeader(title: 'Notification Settings'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsSection(
                      title: 'General',
                      children: [
                        SettingsTile(
                          icon: Icons.notifications_active_rounded,
                          iconColor: const Color(0xFF2563EB),
                          title: 'Enable Notifications',
                          subtitle: 'Master switch for all alerts',
                          trailing: Switch(
                            value: _masterSwitch,
                            onChanged: (val) => _updateSetting(NotificationScheduler.masterSwitchKey, val),
                            activeThumbColor: const Color(0xFF0A84FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Opacity(
                      opacity: _masterSwitch ? 1.0 : 0.5,
                      child: IgnorePointer(
                        ignoring: !_masterSwitch,
                        child: Column(
                          children: [
                            SettingsSection(
                              title: 'Delivery',
                              children: [
                                SettingsTile(
                                  icon: Icons.volume_up_rounded,
                                  iconColor: const Color(0xFF10B981),
                                  title: 'Sound',
                                  subtitle: 'Play sound for notifications',
                                  trailing: Switch(
                                    value: _settings.playSound,
                                    onChanged: (val) => _updateNotificationSettings(_settings.copyWith(playSound: val)),
                                    activeThumbColor: const Color(0xFF0A84FF),
                                  ),
                                ),
                                SettingsTile(
                                  icon: Icons.vibration_rounded,
                                  iconColor: const Color(0xFFF59E0B),
                                  title: 'Vibration',
                                  subtitle: 'Vibrate on delivery',
                                  trailing: Switch(
                                    value: _settings.enableVibration,
                                    onChanged: (val) => _updateNotificationSettings(_settings.copyWith(enableVibration: val)),
                                    activeThumbColor: const Color(0xFF0A84FF),
                                  ),
                                ),
                                SettingsTile(
                                  icon: Icons.visibility_rounded,
                                  iconColor: const Color(0xFF8B5CF6),
                                  title: 'Notification Preview',
                                  subtitle: _settings.previewMode.displayName,
                                  onTap: _showPreviewModeSelector,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            SettingsSection(
                              title: 'Renewal Alerts',
                              children: [
                                SettingsTile(
                                  icon: Icons.calendar_today_rounded,
                                  iconColor: const Color(0xFF8B5CF6),
                                  title: '7 Days Before',
                                  subtitle: 'Alert 7 days in advance',
                                  trailing: Switch(
                                    value: _notify7Days,
                                    onChanged: (val) => _updateSetting(NotificationScheduler.days7Key, val),
                                    activeThumbColor: const Color(0xFF0A84FF),
                                  ),
                                ),
                                SettingsTile(
                                  icon: Icons.calendar_today_rounded,
                                  iconColor: const Color(0xFF8B5CF6),
                                  title: '3 Days Before',
                                  subtitle: 'Alert 3 days in advance',
                                  trailing: Switch(
                                    value: _notify3Days,
                                    onChanged: (val) => _updateSetting(NotificationScheduler.days3Key, val),
                                    activeThumbColor: const Color(0xFF0A84FF),
                                  ),
                                ),
                                SettingsTile(
                                  icon: Icons.calendar_today_rounded,
                                  iconColor: const Color(0xFF8B5CF6),
                                  title: '1 Day Before',
                                  subtitle: 'Alert 1 day in advance',
                                  trailing: Switch(
                                    value: _notify1Day,
                                    onChanged: (val) => _updateSetting(NotificationScheduler.day1Key, val),
                                    activeThumbColor: const Color(0xFF0A84FF),
                                  ),
                                ),
                                SettingsTile(
                                  icon: Icons.notification_important_rounded,
                                  iconColor: const Color(0xFFF59E0B),
                                  title: 'Renewal Day',
                                  subtitle: 'Alert on the exact day',
                                  trailing: Switch(
                                    value: _notifyRenewalDay,
                                    onChanged: (val) => _updateSetting(NotificationScheduler.renewalDayKey, val),
                                    activeThumbColor: const Color(0xFF0A84FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),


                            SettingsSection(
                              title: 'Reports',
                              children: [
                                SettingsTile(
                                  icon: Icons.view_week_rounded,
                                  iconColor: const Color(0xFF3B82F6),
                                  title: 'Weekly Summary',
                                  subtitle: 'Every Sunday morning',
                                  trailing: Switch(
                                    value: _notifyWeekly,
                                    onChanged: (val) => _updateSetting('notify_weekly_summary', val),
                                    activeThumbColor: const Color(0xFF0A84FF),
                                  ),
                                ),
                                SettingsTile(
                                  icon: Icons.calendar_month_rounded,
                                  iconColor: const Color(0xFF3B82F6),
                                  title: 'Monthly Summary',
                                  subtitle: 'First day of every month',
                                  trailing: Switch(
                                    value: _notifyMonthly,
                                    onChanged: (val) => _updateSetting('notify_monthly_summary', val),
                                    activeThumbColor: const Color(0xFF0A84FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            SettingsSection(
                              title: 'Quiet Hours',
                              children: [
                                SettingsTile(
                                  icon: Icons.do_not_disturb_on_rounded,
                                  iconColor: const Color(0xFF6B7280),
                                  title: 'Enable Quiet Hours',
                                  subtitle: 'No notifications during this period',
                                  trailing: Switch(
                                    value: _quietHoursEnabled,
                                    onChanged: (val) => _updateSetting(NotificationScheduler.quietHoursEnabledKey, val),
                                    activeThumbColor: const Color(0xFF0A84FF),
                                  ),
                                ),
                                if (_quietHoursEnabled) ...[
                                  SettingsTile(
                                    icon: Icons.schedule_rounded,
                                    iconColor: const Color(0xFF6B7280),
                                    title: 'Start Time',
                                    subtitle: 'When quiet hours begin',
                                    trailing: Text(_quietStart, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  SettingsTile(
                                    icon: Icons.schedule_rounded,
                                    iconColor: const Color(0xFF6B7280),
                                    title: 'End Time',
                                    subtitle: 'When quiet hours end',
                                    trailing: Text(_quietEnd, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ]
                              ],
                            ),
                            const SizedBox(height: 20),

                            SettingsSection(
                              title: 'Test',
                              children: [
                                SettingsTile(
                                  icon: Icons.bug_report_rounded,
                                  iconColor: const Color(0xFFEF4444),
                                  title: 'Send Test Notification',
                                  subtitle: 'Verify your settings',
                                  onTap: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Notification will be sent in 2 seconds...')),
                                    );
                                    await NotificationService.instance.sendTestNotification();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
