import 'package:flutter/material.dart';
import 'package:sanchora/features/profile/services/profile_service.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/features/subscriptions/presentation/pages/view_subscription_page.dart';
import 'package:sanchora/features/profile/screens/profile_screen.dart';
import 'package:sanchora/core/widgets/app_header.dart';
import 'package:sanchora/core/services/currency_service.dart';
import 'package:sanchora/features/home/widgets/spending_overview_card.dart';
import 'package:sanchora/features/home/widgets/top_categories_card.dart';
import 'package:sanchora/features/home/widgets/hero_summary_card.dart';
import 'package:sanchora/features/home/screens/upcoming_payments_screen.dart';
import 'package:sanchora/features/notifications/services/notification_history_service.dart';
import 'package:sanchora/features/notifications/screens/notifications_inbox_screen.dart';
import 'package:sanchora/core/services/navigation_event_bus.dart';
import 'package:sanchora/core/widgets/sanchora_bottom_nav.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:sanchora/features/settings/screens/appearance_screen.dart';
import 'package:sanchora/features/settings/screens/subscription_calendar_placeholder_screen.dart';
import 'package:sanchora/features/settings/screens/budget_settings_placeholder_screen.dart';
import 'package:sanchora/features/settings/screens/help_feedback_screen.dart';
import 'package:sanchora/features/settings/screens/about_sanchora_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<BottomNavTab>? _navSub;

  @override
  void initState() {
    super.initState();
    _navSub = NavigationEventBus.instance.scrollToTopStream.listen((tab) {
      if (tab == BottomNavTab.home && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _navSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  SubscriptionService.instance,
                  ProfileService.currentUserNotifier,
                ]),
                builder: (context, _) {
                  final user = ProfileService.currentUserNotifier.value;
                  final firstName = user.name.split(' ').first;
                  final hour = DateTime.now().hour;
                  String greeting = 'Good Evening';
                  if (hour < 12) {
                    greeting = 'Good Morning';
                  } else if (hour < 17) {
                    greeting = 'Good Afternoon';
                  }

                  final hasSubscriptions = SubscriptionService.instance.subscriptions.isNotEmpty;

                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$greeting, $firstName',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Stay on top of your subscriptions.",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCard(),
                        const SizedBox(height: 16),
                        if (hasSubscriptions) ...[
                          _buildUpcomingPaymentsCard(),
                          const SizedBox(height: 16),
                          _buildSpendingOverviewCard(),
                          const SizedBox(height: 16),
                          _buildTopCategoriesCard(),
                        ] else
                          _buildEmptyState(),
                        SizedBox(height: isCompact ? 10 : 8),
                      ],
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sanchora',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return InkWell(
      onTap: () => _showGlobalActionsMenu(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140B1F4D),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return ListenableBuilder(
      listenable: NotificationHistoryService.instance,
      builder: (context, _) {
        final unreadCount = NotificationHistoryService.instance.unreadCount;
        
        return InkWell(
          onTap: () => pushScreen(const NotificationsInboxScreen()),
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x140B1F4D),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return HeroSummaryCard();
  }

  Widget _buildUpcomingPaymentsCard() {
    final upcoming = SubscriptionService.instance.upcomingRenewals.take(3).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Upcoming Payments',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () =>
                    pushScreen(const UpcomingPaymentsScreen()),
                borderRadius: BorderRadius.circular(8),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1677FF),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF1677FF),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...upcoming.asMap().entries.map((entry) {
            final sub = entry.value;
            final isLast = entry.key == upcoming.length - 1;
            
            // Format date
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            final formattedDate = '${months[sub.nextRenewalDate.month - 1]} ${sub.nextRenewalDate.day}, ${sub.nextRenewalDate.year}';
            
            // Calculate days left
            final today = DateTime.now();
            final todayMidnight = DateTime(today.year, today.month, today.day);
            final nextMidnight = DateTime(sub.nextRenewalDate.year, sub.nextRenewalDate.month, sub.nextRenewalDate.day);
            final diff = nextMidnight.difference(todayMidnight).inDays;
            
            String daysLeftStr = '';
            if (diff == 0) {
              daysLeftStr = 'Today';
            } else if (diff == 1) {
              daysLeftStr = 'Tomorrow';
            } else if (diff < 0) {
              daysLeftStr = 'Overdue';
            } else {
              daysLeftStr = '$diff days left';
            }

            // Extract color from UI (using default blue if not found, since color isn't in model directly but we can use icon mapping logic or just default)
            // Wait, we need the category color. For simplicity, we can just use a fixed color or extract it from CategoryProvider.
            // But let's just use the primary color for now, since iconUrl is a string.
            // Actually, we can use CategoryProvider.getCategorySummaries to get the color, but for now let's just use a default color.
            
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: _buildPaymentTile(
                subscription: sub,
                name: sub.name,
                date: formattedDate,
                amount: CurrencyService.instance.format(sub.currentPrice),
                daysLeft: daysLeftStr,
                icon: Icons.payments_rounded, // fallback icon
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentTile({
    required SubscriptionModel subscription,
    required String name,
    required String date,
    required String amount,
    required String daysLeft,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => pushScreen(ViewSubscriptionPage(subscription: subscription)),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    daysLeft,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    return SpendingOverviewCard();
  }

  Widget _buildTopCategoriesCard() {
    return const TopCategoriesCard();
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_card_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Subscriptions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first subscription to track spending and get renewal reminders.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showGlobalActionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildActionMenuItem(
                  theme,
                  title: 'Appearance',
                  icon: Icons.palette_rounded,
                  accentColor: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.of(context).pop();
                    pushScreen(const AppearanceScreen());
                  },
                ),
                _buildActionMenuItem(
                  theme,
                  title: 'Share Sanchora',
                  icon: Icons.ios_share_rounded,
                  accentColor: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.of(context).pop();
                    SharePlus.instance.share(ShareParams(text: 'Take control of all your subscriptions with Sanchora.\n\nOne App. Every Subscription.'));
                  },
                ),
                _buildActionMenuItem(
                  theme,
                  title: 'Subscription Calendar',
                  icon: Icons.calendar_month_rounded,
                  accentColor: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.of(context).pop();
                    pushScreen(const SubscriptionCalendarPlaceholderScreen());
                  },
                ),
                _buildActionMenuItem(
                  theme,
                  title: 'Budget Settings',
                  icon: Icons.account_balance_wallet_rounded,
                  accentColor: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.of(context).pop();
                    pushScreen(const BudgetSettingsPlaceholderScreen());
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, thickness: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                _buildActionMenuItem(
                  theme,
                  title: 'Help & Feedback',
                  icon: Icons.help_outline_rounded,
                  accentColor: const Color(0xFF06B6D4),
                  onTap: () {
                    Navigator.of(context).pop();
                    pushScreen(const HelpFeedbackScreen());
                  },
                ),
                _buildActionMenuItem(
                  theme,
                  title: 'About Sanchora',
                  icon: Icons.info_outline_rounded,
                  accentColor: const Color(0xFF64748B),
                  onTap: () {
                    Navigator.of(context).pop();
                    pushScreen(const AboutSanchoraScreen());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionMenuItem(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleBottomNavTap(int index) {
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
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
  });

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
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
    return const UpcomingPaymentsScreen();
  }
}

class CategoriesPlaceholderScreen extends StatelessWidget {
  const CategoriesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Categories',
      message: 'Detailed category analytics will be available soon.',
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
