import 'package:flutter/material.dart';
import '../../../core/widgets/app_header.dart';
import '../services/support_service.dart';
import '../widgets/support_option_tile.dart';
import 'faq_screen.dart';
import 'send_feedback_screen.dart';
import 'report_bug_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HelpFeedbackScreen extends StatefulWidget {
  const HelpFeedbackScreen({super.key});

  @override
  State<HelpFeedbackScreen> createState() => _HelpFeedbackScreenState();
}

class _HelpFeedbackScreenState extends State<HelpFeedbackScreen> {
  String _appVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version}';
      });
    } catch (e) {
      // Ignored
    }
  }

  void _pushScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Help & Feedback',
              leading: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    SupportOptionTile(
                      title: 'Contact Support',
                      subtitle: 'Get help from the Sanchora team.',
                      icon: Icons.mail_outline_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      onTap: () async {
                        final success = await SupportService.instance.contactSupport();
                        if (!context.mounted) return;
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No email client found on this device.')),
                          );
                        }
                      },
                    ),
                    SupportOptionTile(
                      title: 'Send Feedback',
                      subtitle: 'Share your ideas to improve Sanchora.',
                      icon: Icons.lightbulb_outline_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      onTap: () => _pushScreen(const SendFeedbackScreen()),
                    ),
                    SupportOptionTile(
                      title: 'Report a Bug',
                      subtitle: 'Help us fix issues faster.',
                      icon: Icons.bug_report_outlined,
                      iconColor: const Color(0xFFEF4444),
                      onTap: () => _pushScreen(const ReportBugScreen()),
                    ),
                    SupportOptionTile(
                      title: 'FAQ',
                      subtitle: 'Find answers to common questions.',
                      icon: Icons.help_outline_rounded,
                      iconColor: const Color(0xFF10B981),
                      onTap: () => _pushScreen(const FaqScreen()),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Footer
                    Text(
                      'Sanchora $_appVersion',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'One App. Every Subscription.',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Privacy Policy coming soon.')),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Terms & Conditions coming soon.')),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '© 2026 Sanchora',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 40),
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
