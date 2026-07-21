import 'package:flutter/material.dart';
import 'package:sanchora/features/profile/screens/profile_screen.dart';
import 'package:sanchora/core/widgets/app_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 700;

    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: _buildDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'Home',
                leading: _buildMenuButton(),
                center: _buildLogo(),
                actions: [_buildNotificationButton()],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        'Hi, Hemanth 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B1F4D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Here's what's happening with your subscriptions.",
                        style: TextStyle(
                          fontSize: 14.5,
                          color: Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(),
                      const SizedBox(height: 16),
                      _buildUpcomingPaymentsCard(),
                      const SizedBox(height: 16),
                      _buildSpendingOverviewCard(),
                      const SizedBox(height: 16),
                      _buildTopCategoriesCard(),
                      SizedBox(height: isCompact ? 10 : 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/sanchora_logo.png',
          width: 28,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        const Text(
          'Sanchora',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0B1F4D),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return InkWell(
      onTap: () => _scaffoldKey.currentState?.openDrawer(),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140B1F4D),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.menu_rounded, color: Color(0xFF0B1F4D)),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return InkWell(
      onTap: () => pushScreen(const NotificationPlaceholderScreen()),
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140B1F4D),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0B1F4D)),
          ),
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF1677FF),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRow = constraints.maxWidth >= 360;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF1677FF), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A1677FF),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: useRow
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Spent This Month',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '₹2,430',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  '12% ↓',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'vs last month',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryMetric(Icons.subscriptions_rounded, 'Active Subscriptions', '8'),
                        const SizedBox(height: 10),
                        _buildSummaryMetric(Icons.calendar_today_rounded, 'Upcoming Payments', '3'),
                      ],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Spent This Month',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '₹2,430',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '12% ↓',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'vs last month',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildSummaryMetric(Icons.subscriptions_rounded, 'Active Subscriptions', '8'),
                    const SizedBox(height: 10),
                    _buildSummaryMetric(Icons.calendar_today_rounded, 'Upcoming Payments', '3'),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSummaryMetric(IconData icon, String label, String value) {
    return Container(
      width: 116,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPaymentsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B1F4D),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Upcoming Payments',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1F4D),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => pushScreen(const UpcomingPaymentsPlaceholderScreen()),
                borderRadius: BorderRadius.circular(8),
                child: const Text(
                  'View All →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1677FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPaymentTile(
            name: 'Netflix',
            date: 'May 25, 2025',
            amount: '₹649',
            daysLeft: '2 days left',
            icon: Icons.play_circle_fill_rounded,
            color: const Color(0xFFFF3B30),
          ),
          const SizedBox(height: 10),
          _buildPaymentTile(
            name: 'Spotify Premium',
            date: 'May 27, 2025',
            amount: '₹119',
            daysLeft: '4 days left',
            icon: Icons.music_note_rounded,
            color: const Color(0xFF1DB954),
          ),
          const SizedBox(height: 10),
          _buildPaymentTile(
            name: 'Amazon Prime',
            date: 'May 30, 2025',
            amount: '₹179',
            daysLeft: '7 days left',
            icon: Icons.shopping_bag_rounded,
            color: const Color(0xFFFF9900),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile({
    required String name,
    required String date,
    required String amount,
    required String daysLeft,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => pushScreen(const SubscriptionDetailsPlaceholderScreen()),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B1F4D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1F4D),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    daysLeft,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B1F4D),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                'Spending Overview',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1F4D),
                ),
              ),
              Spacer(),
              Text(
                'This Month',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Text(
                '₹2,430',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1F4D),
                ),
              ),
              Spacer(),
              Text(
                'Total Spent',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Jan', 0.42, false),
                _buildBar('Feb', 0.54, false),
                _buildBar('Mar', 0.64, false),
                _buildBar('Apr', 0.72, false),
                _buildBar('May', 0.92, true),
                _buildBar('Jun', 0.68, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor, bool highlight) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 92 * heightFactor,
                  decoration: BoxDecoration(
                    color: highlight ? const Color(0xFF1677FF) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                if (highlight)
                  Positioned(
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1F4D),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '₹2,430',
                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategoriesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B1F4D),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Top Categories',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1F4D),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => pushScreen(const CategoriesPlaceholderScreen()),
                borderRadius: BorderRadius.circular(8),
                child: const Text(
                  'View All →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1677FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 20) / 3;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: cardWidth.clamp(90.0, double.infinity),
                    child: _buildCategoryCard(
                      title: 'Entertainment',
                      amount: '₹1,250',
                      percent: '51%',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth.clamp(90.0, double.infinity),
                    child: _buildCategoryCard(
                      title: 'Shopping',
                      amount: '₹720',
                      percent: '29%',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth.clamp(90.0, double.infinity),
                    child: _buildCategoryCard(
                      title: 'Education',
                      amount: '₹280',
                      percent: '11%',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String amount,
    required String percent,
  }) {
    return InkWell(
      onTap: () => pushScreen(const CategoryDetailsPlaceholderScreen()),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0B1F4D)),
            ),
            const SizedBox(height: 10),
            Text(
              amount,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0B1F4D)),
            ),
            const SizedBox(height: 8),
            Text(
              percent,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1677FF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? const Color(0xFF1677FF) : const Color(0xFF64748B), size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? const Color(0xFF1677FF) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return InkWell(
      onTap: () => handleBottomNavTap(2),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1677FF),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A1677FF),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sanchora',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1F4D),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: const Text('Home'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _selectedIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.subscriptions_rounded),
                title: const Text('Subscriptions'),
                onTap: () {
                  Navigator.of(context).pop();
                  pushScreen(const SubscriptionsPlaceholderScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics_rounded),
                title: const Text('Analytics'),
                onTap: () {
                  Navigator.of(context).pop();
                  pushScreen(const AnalyticsPlaceholderScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_rounded),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.of(context).pop();
                  pushScreen(const ProfileScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(context).pop();
                  pushScreen(const SettingsPlaceholderScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleBottomNavTap(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        pushScreen(const SubscriptionsPlaceholderScreen());
        break;
      case 2:
        pushScreen(const AddSubscriptionPlaceholderScreen());
        break;
      case 3:
        pushScreen(const AnalyticsPlaceholderScreen());
        break;
      case 4:
        pushScreen(const ProfileScreen());
        break;
    }
  }

  void pushScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: title,
              leading: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(14),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.arrow_back_rounded, color: Color(0xFF0B1F4D)),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Placeholder content
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionsPlaceholderScreen extends StatelessWidget {
  const SubscriptionsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Subscriptions',
      message: 'Subscriptions Screen',
    );
  }
}

class AddSubscriptionPlaceholderScreen extends StatelessWidget {
  const AddSubscriptionPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Add Subscription',
      message: 'Add Subscription Screen',
    );
  }
}

class AnalyticsPlaceholderScreen extends StatelessWidget {
  const AnalyticsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Analytics',
      message: 'Analytics Screen',
    );
  }
}

class NotificationPlaceholderScreen extends StatelessWidget {
  const NotificationPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Notifications',
      message: 'Notification Screen',
    );
  }
}

class UpcomingPaymentsPlaceholderScreen extends StatelessWidget {
  const UpcomingPaymentsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Upcoming Payments',
      message: 'Upcoming Payments Screen',
    );
  }
}

class SubscriptionDetailsPlaceholderScreen extends StatelessWidget {
  const SubscriptionDetailsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Subscription Details',
      message: 'Subscription Details Screen',
    );
  }
}

class CategoriesPlaceholderScreen extends StatelessWidget {
  const CategoriesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Categories',
      message: 'Categories Screen',
    );
  }
}

class CategoryDetailsPlaceholderScreen extends StatelessWidget {
  const CategoryDetailsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Category Details',
      message: 'Category Details Screen',
    );
  }
}

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Settings',
      message: 'Settings Screen',
    );
  }
}