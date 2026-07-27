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
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: const [
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
                  context,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  tab: BottomNavTab.home,
                ),
                _buildItem(
                  context,
                  icon: Icons.subscriptions_rounded,
                  label: 'Subs',
                  tab: BottomNavTab.subs,
                ),
                _buildCenterSpacer(),
                _buildItem(
                  context,
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  tab: BottomNavTab.analytics,
                ),
                _buildItem(
                  context,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  tab: BottomNavTab.profile,
                ),
              ],
            ),
          ),
          Positioned(
            top: -16,
            child: _buildCenterButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, {
    required IconData icon,
    required String label,
    required BottomNavTab tab,
  }) {
    final bool isSelected = selectedTab == tab;
    final Color color = isSelected ? _selectedColor : Theme.of(context).colorScheme.onSurfaceVariant;

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

  Widget _buildCenterButton(BuildContext context) {
    final bool isSelected = selectedTab == BottomNavTab.add;
    final Color labelColor = isSelected ? _selectedColor : Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => onTabSelected(BottomNavTab.add),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x241677FF),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 26,
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