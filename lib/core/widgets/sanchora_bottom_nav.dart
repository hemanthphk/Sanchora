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
          CustomPaint(
            painter: _NavCustomPainter(
              color: Theme.of(context).colorScheme.surface,
              shadowColor: const Color(0x14000000), // Softer premium shadow
            ),
            child: SizedBox(
              height: 78,
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
          ),
          Positioned(
            top: 2, // Lowered by 10px from -8
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
    final Color color = isSelected ? _selectedColor : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.75);

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(tab),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 78,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? _selectedColor.withValues(alpha: 0.10) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 26 : 24,
                  color: color,
                ),
              ),
              SizedBox(height: isSelected ? 2 : 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
              color: const Color(0xFF0A84FF).withValues(alpha: 0.20), // Reduced shadow intensity
              blurRadius: 12,
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
            onTap: () {
              _controller.forward().then((_) {
                _controller.reverse();
                widget.onTap();
              });
            },
            customBorder: const CircleBorder(),
            splashColor: Colors.white.withValues(alpha: 0.25),
            highlightColor: Colors.transparent,
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28, // Increased icon size (+2px)
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCustomPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  _NavCustomPainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final path = Path();
    final double radius = 32.0;

    // Center geometry
    final double centerX = size.width / 2;
    final double holeWidth = 52.0;
    final double depth = 46.0;

    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    path.lineTo(centerX - holeWidth, 0);
    path.cubicTo(
      centerX - 24, 0,
      centerX - 28, depth,
      centerX, depth,
    );
    path.cubicTo(
      centerX + 28, depth,
      centerX + 24, 0,
      centerX + holeWidth, 0,
    );

    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow path shifted up for floating effect
    canvas.drawPath(path.shift(const Offset(0, -6)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}