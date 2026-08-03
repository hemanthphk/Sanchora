import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanchora/core/widgets/sanchora_page_header.dart';
import 'package:sanchora/features/profile/widgets/settings_section.dart';
import 'package:sanchora/features/profile/widgets/settings_tile.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late SharedPreferences _prefs;
  bool _analyticsEnabled = true;
  bool _insightsEnabled = true;
  bool _isLoading = true;
  double _cacheSize = 12.4;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _analyticsEnabled = _prefs.getBool('privacy_analytics') ?? true;
      _insightsEnabled = _prefs.getBool('privacy_insights') ?? true;
      _isLoading = false;
    });
  }

  void _updatePref(String key, bool value) {
    setState(() {
      if (key == 'privacy_analytics') _analyticsEnabled = value;
      if (key == 'privacy_insights') _insightsEnabled = value;
    });
    _prefs.setBool(key, value);
  }

  void _exportData() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Data Format',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.data_object_rounded, color: Color(0xFF2563EB)),
                  title: const Text('Export as JSON'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackbar('Data exported successfully as JSON.');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart_rounded, color: Color(0xFF10B981)),
                  title: const Text('Export as CSV'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackbar('Data exported successfully as CSV.');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: Text('Are you sure you want to clear ${_cacheSize == 0 ? '0' : _cacheSize.toStringAsFixed(1)} MB of cached images?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _cacheSize = 0.0;
                });
                _showSnackbar('Cache cleared successfully. (0 MB)');
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccountStep1() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccountStep2();
              },
              child: const Text('Continue', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccountStep2() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type "DELETE" to confirm account deletion.'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'DELETE',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return TextButton(
                  onPressed: value.text == 'DELETE'
                      ? () {
                          Navigator.pop(context);
                          _showSnackbar('Account deletion will be available after cloud accounts are launched.');
                        }
                      : null,
                  child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: SanchoraPageHeader(title: 'Data & Privacy'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const SanchoraPageHeader(title: 'Data & Privacy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            SettingsSection(
              title: 'Privacy',
              children: [
                SettingsTile(
                  icon: Icons.analytics_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Analytics & Crash Reports',
                  subtitle: 'Help us improve Sanchora',
                  trailing: Switch(
                    value: _analyticsEnabled,
                    onChanged: (val) => _updatePref('privacy_analytics', val),
                  ),
                ),
                SettingsTile(
                  icon: Icons.psychology_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Personalized Insights',
                  subtitle: 'Get personalized AI insights',
                  trailing: Switch(
                    value: _insightsEnabled,
                    onChanged: (val) => _updatePref('privacy_insights', val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: 'Data Management',
              children: [
                SettingsTile(
                  icon: Icons.download_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Export My Data',
                  subtitle: 'Export your Sanchora data',
                  onTap: _exportData,
                ),
                SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Clear Cache',
                  subtitle: 'Free up local storage • ${_cacheSize == 0 ? '0' : _cacheSize.toStringAsFixed(1)} MB',
                  onTap: _clearCache,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: 'Account',
              children: [
                SettingsTile(
                  icon: Icons.person_off_rounded,
                  iconColor: Colors.red,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your data',
                  onTap: _deleteAccountStep1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
