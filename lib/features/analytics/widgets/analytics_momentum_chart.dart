import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'dart:math' as math;

class AnalyticsMomentumChart extends StatefulWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsMomentumChart({
    super.key,
    required this.subscriptions,
  });

  @override
  State<AnalyticsMomentumChart> createState() => _AnalyticsMomentumChartState();
}

class _AnalyticsMomentumChartState extends State<AnalyticsMomentumChart> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    if (widget.subscriptions.isEmpty) return const SizedBox.shrink();

    // Calculate momentum based on recent additions
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    double currentSpend = 0;
    double previousSpend = 0;

    for (var sub in widget.subscriptions) {
      if (sub.status == SubscriptionStatus.active || sub.status == SubscriptionStatus.upcoming) {
        final monthlyCost = sub.billingCycle == BillingCycle.monthly ? sub.monthlyPrice : sub.yearlyPrice / 12;
        currentSpend += monthlyCost;
        if (sub.startDate.isBefore(thirtyDaysAgo)) {
          previousSpend += monthlyCost;
        }
      }
    }

    int percentChange = 0;
    if (previousSpend > 0) {
      percentChange = (((currentSpend - previousSpend) / previousSpend) * 100).round();
    } else if (currentSpend > 0) {
      percentChange = 100;
    }

    String percentText = percentChange > 0 ? '+$percentChange%' : '$percentChange%';
    Color momentumColor = AppColors.primary;
    List<double> points = [0.2, 0.4, 0.3, 0.5, 0.5, 0.5]; // Baseline stable points

    if (percentChange > 5) {
      momentumColor = AppColors.error;
      points = [0.2, 0.3, 0.2, 0.4, 0.7, 0.9]; // Upward trend
    } else if (percentChange < -5) {
      momentumColor = AppColors.success;
      points = [0.8, 0.7, 0.9, 0.5, 0.3, 0.2]; // Downward trend
    }

    double maxVal = math.max(currentSpend, previousSpend);
    if (maxVal == 0) maxVal = 1000;
    final chartMax = maxVal * 1.5; // Give headroom

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: momentumColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.show_chart_rounded, color: momentumColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Spending Momentum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    percentText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: momentumColor,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Last 30 Days',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  painter: _SparklinePainter(
                    points: points,
                    color: momentumColor,
                    progress: value,
                    theme: theme,
                    maxValue: chartMax,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  percentChange > 0 ? Icons.arrow_upward_rounded : (percentChange < 0 ? Icons.arrow_downward_rounded : Icons.horizontal_rule_rounded),
                  color: percentChange == 0 ? theme.colorScheme.onSurfaceVariant : momentumColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${percentChange.abs()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'vs Previous 30 Days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final double progress;
  final ThemeData theme;
  final double maxValue;

  _SparklinePainter({
    required this.points,
    required this.color,
    required this.progress,
    required this.theme,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double bottomPadding = 20.0;
    final double leftPadding = 42.0;
    
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding;

    final paintLine = Paint()
      ..color = theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
      ..strokeWidth = 1;
      
    final textStyle = TextStyle(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    int ySteps = 2;
    for (int i = 0; i <= ySteps; i++) {
      double y = chartHeight - (i * (chartHeight / ySteps));
      double val = (maxValue / ySteps) * i;
      
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), paintLine);
      
      final tp = TextPainter(
        text: TextSpan(text: '₹${val.toInt()}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 8, y - tp.height / 2));
    }

    final stepX = chartWidth / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final x = leftPadding + (i * stepX);
      if (i % 2 == 0 || i == points.length - 1) { 
        final tp = TextPainter(
          text: TextSpan(text: 'Wk ${i + 1}', style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, chartHeight + 6));
      }
    }

    final path = Path();
    final fillPath = Path();
    
    final visibleWidth = chartWidth * progress;
    
    double startY = chartHeight - (points[0] * chartHeight);
    path.moveTo(leftPadding, startY);
    fillPath.moveTo(leftPadding, chartHeight);
    fillPath.lineTo(leftPadding, startY);
    
    for (int i = 0; i < points.length - 1; i++) {
      final x1 = leftPadding + (i * stepX);
      final y1 = chartHeight - (points[i] * chartHeight);
      final x2 = leftPadding + ((i + 1) * stepX);
      final y2 = chartHeight - (points[i + 1] * chartHeight);
      
      final cx = (x1 + x2) / 2;
      
      if ((x2 - leftPadding) <= visibleWidth) {
        path.cubicTo(cx, y1, cx, y2, x2, y2);
        fillPath.cubicTo(cx, y1, cx, y2, x2, y2);
      } else if ((x1 - leftPadding) < visibleWidth) {
        final t = (visibleWidth - (x1 - leftPadding)) / (x2 - x1);
        final currY = y1 + (y2 - y1) * t;
        final currX = leftPadding + visibleWidth;
        path.lineTo(currX, currY);
        fillPath.lineTo(currX, currY);
        break;
      }
    }
    
    fillPath.lineTo(leftPadding + visibleWidth, chartHeight);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: 0.15),
        color.withValues(alpha: 0.0),
      ],
    );
    
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(leftPadding, 0, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    canvas.drawPath(path, linePaint);
    
    if (progress > 0) {
      int lastIdx = (progress * (points.length - 1)).floor();
      if (lastIdx >= points.length) lastIdx = points.length - 1;
      
      double exactX = leftPadding + visibleWidth;
      double exactY = 0;
      
      if (lastIdx < points.length - 1) {
        final x1 = leftPadding + (lastIdx * stepX);
        final y1 = chartHeight - (points[lastIdx] * chartHeight);
        final y2 = chartHeight - (points[lastIdx + 1] * chartHeight);
        final t = (exactX - x1) / stepX;
        exactY = y1 + (y2 - y1) * t; 
      } else {
        exactY = chartHeight - (points.last * chartHeight);
      }
      
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
        
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(exactX, exactY), 6, shadowPaint);
      canvas.drawCircle(Offset(exactX, exactY), 4, dotPaint);
      canvas.drawCircle(Offset(exactX, exactY), 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
