import 'package:flutter/material.dart';
import 'package:sanchora/features/auth/screens/login_screen.dart';
import 'package:sanchora/features/home/screens/home_screen.dart';
import 'package:sanchora/core/theme/theme_controller.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/logout_button.dart';
import '../../add_subscription/presentation/pages/add_subscription_page.dart';
import '../../analytics/screens/analytics_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _animationController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _analyticsFade;
  late final Animation<Offset> _analyticsSlide;
  late final Animation<double> _settingsFade;
  late final Animation<Offset> _settingsSlide;
  late final Animation<double> _logoutFade;
  late final Animation<Offset> _logoutSlide;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _headerFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    ));

    _analyticsFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOut),
    );
    _analyticsSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
    ));

    _settingsFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOut),
    );
    _settingsSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOutCubic),
    ));

    _logoutFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.45, 0.90, curve: Curves.easeOut),
    );
    _logoutSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.45, 0.90, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ProfileAppBar(
        onNotificationTap: () => _openScreen(context, const NotificationScreen()),
      ),
      drawer: _buildDrawer(theme),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Animated Profile Header Card
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: ProfileHeaderCard(
                  name: 'Hemanth Paruchuri',
                  email: 'hemanth@example.com',
                  avatarInitials: 'HP',
                  isPremium: true,
                  onTap: () => _openScreen(context, const ProfileDetailsScreen()),
                  onEditAvatarTap: () => _openScreen(context, const ProfileDetailsScreen()),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Animated Analytics Container
            SlideTransition(
              position: _analyticsSlide,
              child: FadeTransition(
                opacity: _analyticsFade,
                child: AnalyticsSummaryCard(
                  totalSubscriptions: '18',
                  totalSpent: CurrencyFormatter.format(2400, compact: true),
                  totalSaved: CurrencyFormatter.format(480),
                  memberSince: 'Oct 2023',
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Animated Account Section
            SlideTransition(
              position: _settingsSlide,
              child: FadeTransition(
                opacity: _settingsFade,
                child: SettingsSection(
                  title: 'Account',
                  children: [
                    SettingsTile(
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF2563EB),
                      title: 'Personal Information',
                      subtitle: 'Update your personal details',
                      onTap: () => _openScreen(context, const PersonalInfoScreen()),
                    ),
                    SettingsTile(
                      icon: Icons.workspace_premium_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Subscription to Premium',
                      subtitle: 'Manage your premium benefits',
                      onTap: () => _openScreen(context, const PremiumScreen()),
                    ),
                    SettingsTile(
                      icon: Icons.credit_card_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Billing & Payments',
                      subtitle: 'Payment history and invoices',
                      onTap: () => _openScreen(context, const BillingScreen()),
                    ),
                    SettingsTile(
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFFEA580C),
                      title: 'Notification Settings',
                      subtitle: 'Control your alerts',
                      onTap: () => _openScreen(context, const NotificationScreen()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Animated Preferences Section
            SlideTransition(
              position: _settingsSlide,
              child: FadeTransition(
                opacity: _settingsFade,
                child: ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) {
                    return SettingsSection(
                      title: 'Preferences',
                      children: [
                        SettingsTile(
                          icon: Icons.currency_rupee_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'Currency',
                          subtitle: 'INR • Indian Rupee',
                          onTap: () => _openScreen(context, const CurrencyScreen()),
                        ),
                        SettingsTile(
                          icon: themeController.isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          iconColor: const Color(0xFF2563EB),
                          title: 'Dark Mode',
                          subtitle: 'Switch between light and dark',
                          onTap: () => themeController.toggleTheme(),
                          trailing: Switch(
                            value: themeController.isDarkMode,
                            onChanged: (value) => themeController.toggleTheme(),
                            activeThumbColor: const Color(0xFF0A84FF),
                          ),
                        ),
                        SettingsTile(
                          icon: Icons.lock_rounded,
                          iconColor: const Color(0xFFF87171),
                          title: 'Data & Privacy',
                          subtitle: 'Secure your account data',
                          onTap: () => _openScreen(context, const PrivacyScreen()),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Animated Support Section
            SlideTransition(
              position: _settingsSlide,
              child: FadeTransition(
                opacity: _settingsFade,
                child: SettingsSection(
                  title: 'Support',
                  children: [
                    SettingsTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: const Color(0xFF2563EB),
                      title: 'Help & FAQs',
                      subtitle: 'Find answers quickly',
                      onTap: () => _openScreen(context, const FaqScreen()),
                    ),
                    SettingsTile(
                      icon: Icons.support_agent_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Contact Support',
                      subtitle: 'Reach out for help',
                      onTap: () => _openScreen(context, const ContactScreen()),
                    ),
                    SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'About Sanchora',
                      subtitle: 'Learn more about the app',
                      onTap: () => _openScreen(context, const AboutScreen()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Animated Logout Button
            SlideTransition(
              position: _logoutSlide,
              child: FadeTransition(
                opacity: _logoutFade,
                child: LogoutButton(
                  onPressed: _showLogoutDialog,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      backgroundColor: theme.cardColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sanchora',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: const Text('Home'),
                onTap: () => _handleBottomNav(context, 0),
              ),
              ListTile(
                leading: const Icon(Icons.subscriptions_rounded),
                title: const Text('Subscriptions'),
                onTap: () => _handleBottomNav(context, 1),
              ),
              ListTile(
                leading: const Icon(Icons.analytics_rounded),
                title: const Text('Analytics'),
                onTap: () => _handleBottomNav(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBottomNav(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        _openScreen(context, const HomeScreen());
        break;
      case 1:
        _openScreen(context, const SubscriptionsPlaceholderScreen());
        break;
      case 2:
        _openScreen(context, const AddSubscriptionPage());
        break;
      case 3:
        _openScreen(context, const AnalyticsScreen());
        break;
      case 4:
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }
}

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: const Center(child: Text('Personal Information Screen')),
    );
  }
}

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: const Center(child: Text('Premium Screen')),
    );
  }
}

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing & Payments')),
      body: const Center(child: Text('Billing Screen')),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Notification Screen')),
    );
  }
}

class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency')),
      body: const Center(child: Text('Currency Screen')),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data & Privacy')),
      body: const Center(child: Text('Privacy Screen')),
    );
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQs')),
      body: const Center(child: Text('FAQ Screen')),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: const Center(child: Text('Contact Screen')),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Sanchora')),
      body: const Center(child: Text('About Screen')),
    );
  }
}

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Details')),
      body: const Center(child: Text('Profile Details Screen')),
    );
  }
}

class SubscriptionsPlaceholderScreen extends StatelessWidget {
  const SubscriptionsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: const Center(child: Text('Subscriptions Screen')),
    );
  }
}