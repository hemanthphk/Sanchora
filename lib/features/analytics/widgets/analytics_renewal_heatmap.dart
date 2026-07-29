import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AnalyticsRenewalHeatmap extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsRenewalHeatmap({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (subscriptions.isEmpty) return const SizedBox.shrink();

    // Find upcoming renewals for the next 90 days
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 90));
    
    Map<String, int> renewalCounts = {};
    Map<String, DateTime> renewalDates = {};

    for (var sub in subscriptions) {
      if (sub.status != SubscriptionStatus.active && sub.status != SubscriptionStatus.upcoming) continue;
      
      DateTime next = sub.nextRenewalDate;
      while (next.isBefore(endDate)) {
        if (next.isAfter(now.subtract(const Duration(days: 1)))) {
          final dateKey = '${next.year}-${next.month}-${next.day}';
          renewalCounts[dateKey] = (renewalCounts[dateKey] ?? 0) + 1;
          renewalDates[dateKey] = next;
        }
        
        // Advance to next cycle
        if (sub.billingCycle == BillingCycle.monthly) {
          next = DateTime(next.year, next.month + 1, next.day);
        } else {
          next = DateTime(next.year + 1, next.month, next.day);
        }
      }
    }

    // Sort dates
    final sortedKeys = renewalCounts.keys.toList()
      ..sort((a, b) => renewalDates[a]!.compareTo(renewalDates[b]!));

    final clusters = sortedKeys.where((k) => renewalCounts[k]! > 0).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Renewal Load (Next 90 Days)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (clusters.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                'No upcoming renewals in the next 90 days.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: clusters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final date = renewalDates[clusters[index]]!;
                  final count = renewalCounts[clusters[index]]!;
                  
                  // Heatmap colors based on count
                  Color cardColor;
                  Color textColor;
                  if (count >= 3) {
                    cardColor = AppColors.error.withValues(alpha: 0.15);
                    textColor = AppColors.error;
                  } else if (count == 2) {
                    cardColor = AppColors.warning.withValues(alpha: 0.15);
                    textColor = AppColors.warning;
                  } else {
                    cardColor = theme.colorScheme.surface;
                    textColor = theme.colorScheme.onSurface;
                  }

                  return Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: count > 1 ? textColor.withValues(alpha: 0.5) : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM d').format(date),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          count == 1 ? 'renewal' : 'renewals',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
