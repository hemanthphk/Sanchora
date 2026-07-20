import 'package:flutter/material.dart';
import 'package:sanchora/core/widgets/sanchora_bottom_nav.dart';

import '../home/screens/home_screen.dart';
import '../profile/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    Scaffold(
      body: Center(child: Text('Subscriptions')),
    ),
    Scaffold(
      body: Center(child: Text('Add Subscription')),
    ),
    Scaffold(
      body: Center(child: Text('Analytics')),
    ),
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
          setState(() {
            _currentIndex = tab.index;
          });
        },
      ),
    );
  }
}