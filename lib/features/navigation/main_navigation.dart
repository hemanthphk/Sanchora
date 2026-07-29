import 'package:flutter/material.dart';
import 'package:sanchora/core/widgets/sanchora_bottom_nav.dart';

import '../home/screens/home_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../subscriptions/screens/subscriptions_screen.dart';
import '../add_subscription/presentation/pages/add_subscription_page.dart';

import '../analytics/screens/analytics_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SubscriptionsScreen(),
    AddSubscriptionPage(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SanchoraBottomNav(
        selectedTab: BottomNavTab.values[_currentIndex],
        onTabSelected: (tab) {
          if (tab == BottomNavTab.add) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddSubscriptionPage()),
            ).then((result) {
              if (result == true && mounted) {
                setState(() {
                  _currentIndex = 1;
                });
              }
            });
            return;
          }
          setState(() {
            _currentIndex = tab.index;
          });
        },
      ),
    );
  }
}