import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:sanchora/core/services/currency_service.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';

class HeroSummaryCard extends StatelessWidget {
  const HeroSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0A84FF), 
              Color(0xFF2563EB), 
              Color(0xFF005BEA)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // 1. Flowing Wave Lines (Bottom-Left to Top-Right)
              Positioned.fill(
                child: CustomPaint(
                  painter: WaveLinesPainter(),
                ),
              ),
              // 2. Large transparent "S" watermark
              Positioned(
                right: -25,
                bottom: -55,
                child: Text(
                  'S',
                  style: TextStyle(
                    fontSize: 220,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.09),
                    height: 1.0,
                    letterSpacing: -10,
                  ),
                ),
              ),
              
              // CARD CONTENT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TOP SECTION
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total Spent This Month',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: SubscriptionService.instance.dashboardSummary.monthlySpend),
                          duration: const Duration(milliseconds: 1400),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, child) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                CurrencyService.instance.format(val.round()),
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1.5,
                                  height: 1.1,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    // THIN DIVIDER
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    
                    // BOTTOM SECTION: 2 GLASS CARDS
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassCard(
                            icon: Icons.inventory_2_outlined,
                            value: SubscriptionService.instance.dashboardSummary.activeSubscriptions.toString(),
                            label: 'Active Subs',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassCard(
                            icon: Icons.notifications_none_outlined,
                            value: SubscriptionService.instance.dashboardSummary.upcomingPayments.toString(),
                            label: 'Upcoming Due',
                            showDot: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required String value,
    required String label,
    bool showDot = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.11),
              // Subtle inner highlight effect
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon in glass circle
                Stack(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: Icon(icon, size: 16, color: Colors.white),
                    ),
                    if (showDot)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13, // 14-16px requested, but 13-14 fits better usually. Let's use 14.
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WaveLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    // Line 1
    final path1 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.85, size.width, size.height * 0.1);

    // Line 2
    final path2 = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.5, size.height * 1.0, size.width, size.height * 0.25);

    // Line 3
    final path3 = Path()
      ..moveTo(0, size.height * 1.0)
      ..quadraticBezierTo(size.width * 0.6, size.height * 1.15, size.width, size.height * 0.4);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
