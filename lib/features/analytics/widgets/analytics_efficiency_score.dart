import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/theme/app_colors.dart';

class AnalyticsEfficiencyScore extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsEfficiencyScore({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (subscriptions.isEmpty) return const SizedBox.shrink();

    int score = 100;
    
    // Penalize for duplicate categories
    Map<String, int> categoryCounts = {};
    for (var sub in subscriptions) {
      if (sub.status == SubscriptionStatus.active || sub.status == SubscriptionStatus.upcoming) {
        categoryCounts[sub.category] = (categoryCounts[sub.category] ?? 0) + 1;
      }
    }
    
    int duplicates = 0;
    categoryCounts.forEach((key, value) {
      if (value > 1) {
        duplicates += (value - 1);
        score -= (value - 1) * 5; // -5 for each overlapping service
      }
    });

    // Penalize for very new subscriptions (potential churn)
    final now = DateTime.now();
    for (var sub in subscriptions) {
      if (now.difference(sub.startDate).inDays < 60) {
        score -= 2; // -2 for new unproven subs
      }
    }

    // Ensure score is within realistic bounds
    score = score.clamp(40, 98);

    String grade = "Excellent";
    String message = "Your subscriptions provide high value with minimal overlap.";
    Color scoreColor = AppColors.success;
    
    if (score < 70) {
      grade = "Needs Attention";
      message = "You have high category overlap. Consider cancelling unused services.";
      scoreColor = AppColors.error;
    } else if (score < 85) {
      grade = "Good";
      message = "Your efficiency is okay, but there's room for optimization.";
      scoreColor = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha: 0.15),
            scoreColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scoreColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Efficiency Score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Icon(Icons.stars_rounded, color: scoreColor),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: score.toDouble()),
                duration: const Duration(milliseconds: 2000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: scoreColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              grade,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (duplicates > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  '$duplicates overlapping subscriptions detected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
