import 'package:flutter/material.dart';

enum BottomNavTab {
  home,
  subs,
  add,
  analytics,
  profile,
}

class SanchoraBottomNav extends StatelessWidget {
  const SanchoraBottomNav({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final BottomNavTab selectedTab;
  final ValueChanged<BottomNavTab> onTabSelected;

  static const Color _selectedColor = Color(0xFF1677FF);
  static const Color _unselectedColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 78,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 18,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  tab: BottomNavTab.home,
                ),
                _buildItem(
                  icon: Icons.subscriptions_rounded,
                  label: 'Subs',
                  tab: BottomNavTab.subs,
                ),
                _buildCenterSpacer(),
                _buildItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  tab: BottomNavTab.analytics,
                ),
                _buildItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  tab: BottomNavTab.profile,
                ),
              ],
            ),
          ),
          Positioned(
            top: -22,
            child: _buildCenterButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required BottomNavTab tab,
  }) {
    final bool isSelected = selectedTab == tab;
    final Color color = isSelected ? _selectedColor : _unselectedColor;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(tab),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 78,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterSpacer() {
    return const SizedBox(width: 80);
  }

  Widget _buildCenterButton() {
    final bool isSelected = selectedTab == BottomNavTab.add;
    final Color labelColor = isSelected ? _selectedColor : _unselectedColor;

    return GestureDetector(
      onTap: () => onTabSelected(BottomNavTab.add),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x331677FF),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}