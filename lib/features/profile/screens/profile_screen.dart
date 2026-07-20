import 'package:flutter/material.dart';
import 'package:sanchora/features/auth/screens/login_screen.dart';
import 'package:sanchora/features/home/screens/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode
        ? ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1677FF),
              brightness: Brightness.dark,
            ),
          )
        : ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1677FF),
              brightness: Brightness.light,
            ),
          );

    return Theme(
      data: theme,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: _buildDrawer(theme),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leadingWidth: 54,
          leading: IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF0B1F4D)),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF1677FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Sanchora',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1F4D),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => _openScreen(context, const NotificationScreen()),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none_rounded, color: Color(0xFF0B1F4D)),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildProfileCard(theme),
                      const SizedBox(height: 20),
                      _buildStatisticsSection(theme),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Account',
                        children: [
                          _buildProfileTile(
                            context,
                            icon: Icons.person_outline_rounded,
                            title: 'Personal Information',
                            subtitle: 'Update your personal details',
                            onTap: () => _openScreen(context, const PersonalInfoScreen()),
                            theme: theme,
                          ),
                          _buildProfileTile(
                            context,
                            icon: Icons.workspace_premium_outlined,
                            title: 'Subscription to Premium',
                            subtitle: 'Manage your premium benefits',
                            onTap: () => _openScreen(context, const PremiumScreen()),
                            theme: theme,
                          ),
                          _buildProfileTile(
                            context,
                            icon: Icons.credit_card_outlined,
                            title: 'Billing & Payments',
                            subtitle: 'Payment history and invoices',
                            onTap: () => _openScreen(context, const BillingScreen()),
                            theme: theme,
                          ),
                          _buildProfileTile(
                            context,
                            icon: Icons.notifications_none_rounded,
                            title: 'Notification Settings',
                            subtitle: 'Control your alerts',
                            onTap: () => _openScreen(context, const NotificationScreen()),
                            theme: theme,
                          ),
                        ],
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'Preferences',
                        children: [
                          _buildProfileTile(
                            context,
                            icon: Icons.currency_rupee_rounded,
                            title: 'Currency',
                            subtitle: 'INR • Indian Rupee',
                            onTap: () => _openScreen(context, const CurrencyScreen()),
                            theme: theme,
                          ),
                          _buildDarkModeTile(theme),
                          _buildProfileTile(
                            context,
                            icon: Icons.lock_outline_rounded,
                            title: 'Data & Privacy',
                            subtitle: 'Secure your account data',
                            onTap: () => _openScreen(context, const PrivacyScreen()),
                            theme: theme,
                          ),
                        ],
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'Support',
                        children: [
                          _buildProfileTile(
                            context,
                            icon: Icons.help_outline_rounded,
                            title: 'Help & FAQs',
                            subtitle: 'Find answers quickly',
                            onTap: () => _openScreen(context, const FaqScreen()),
                            theme: theme,
                          ),
                          _buildProfileTile(
                            context,
                            icon: Icons.support_agent_outlined,
                            title: 'Contact Support',
                            subtitle: 'Reach out for help',
                            onTap: () => _openScreen(context, const ContactScreen()),
                            theme: theme,
                          ),
                          _buildProfileTile(
                            context,
                            icon: Icons.info_outline_rounded,
                            title: 'About Sanchora',
                            subtitle: 'Learn more about the app',
                            onTap: () => _openScreen(context, const AboutScreen()),
                            theme: theme,
                          ),
                        ],
                        theme: theme,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _showLogoutDialog,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                            foregroundColor: const Color(0xFFEF4444),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0B1F4D),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Manage your account and preferences.',
          style: TextStyle(
            fontSize: 14.5,
            color: Color(0xFF64748B),
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
    return InkWell(
      onTap: () => _openScreen(context, const ProfileDetailsScreen()),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140B1F4D),
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1677FF), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'HP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: Color(0xFF1677FF)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hemanth Paruchuri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF64748B)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'hemanth@example.com',
                    style: TextStyle(fontSize: 13.5, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFF1677FF)),
                        SizedBox(width: 6),
                        Text(
                          'Premium Plan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1677FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme) {
    final stats = [
      _StatItem(icon: Icons.subscriptions_rounded, title: 'Total Subscriptions', value: '18', subtitle: 'Active plans'),
      _StatItem(icon: Icons.account_balance_wallet_outlined, title: 'Total Spent', value: '₹2.4k', subtitle: 'This month'),
      _StatItem(icon: Icons.savings_outlined, title: 'Total Saved', value: '₹480', subtitle: 'Annual value'),
      _StatItem(icon: Icons.calendar_today_rounded, title: 'Member Since', value: '2023', subtitle: 'Joined'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 700 ? 4 : 2;
        final itemWidth = (constraints.maxWidth - (crossCount - 1) * 12) / crossCount;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats.map((item) {
            return SizedBox(
              width: itemWidth,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.85)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(item.icon, size: 18, color: const Color(0xFF1677FF)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: TextStyle(fontSize: 12.5, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSection({required String title, required List<Widget> children, required ThemeData theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0B1F4D),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: const Color(0xFF1677FF)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.5, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeTile(ThemeData theme) {
    return InkWell(
      onTap: () => setState(() => _isDarkMode = !_isDarkMode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                size: 20,
                color: const Color(0xFF1677FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Switch between light and dark',
                    style: TextStyle(fontSize: 12.5, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isDarkMode,
              onChanged: (value) => setState(() => _isDarkMode = value),
              activeThumbColor: const Color(0xFF1677FF),
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
        _openScreen(context, const SubscriptionsScreen());
        break;
      case 2:
        _openScreen(context, const AddSubscriptionScreen());
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
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _StatItem {
  const _StatItem({required this.icon, required this.title, required this.value, required this.subtitle});

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
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

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: const Center(child: Text('Subscriptions Screen')),
    );
  }
}

class AddSubscriptionScreen extends StatelessWidget {
  const AddSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subscription')),
      body: const Center(child: Text('Add Subscription Screen')),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Analytics Screen')),
    );
  }
}
