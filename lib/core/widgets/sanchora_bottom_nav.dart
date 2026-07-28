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
            top: -8,
            child: _CenterAddButton(
              onTap: () => onTabSelected(BottomNavTab.add),
            ),
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

}

class _CenterAddButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CenterAddButton({required this.onTap});

  @override
  State<_CenterAddButton> createState() => _CenterAddButtonState();
}

class _CenterAddButtonState extends State<_CenterAddButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF0A84FF), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A84FF).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTapDown: (_) => _controller.forward(),
            onTapCancel: () => _controller.reverse(),
            onHighlightChanged: (isHighlighted) {
              if (!isHighlighted) _controller.reverse();
            },
            onTap: widget.onTap,
            customBorder: const CircleBorder(),
            splashColor: Colors.white.withValues(alpha: 0.25),
            highlightColor: Colors.transparent,
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}