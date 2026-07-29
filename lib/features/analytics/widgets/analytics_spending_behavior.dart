import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/theme/app_colors.dart';

class AnalyticsSpendingBehavior extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsSpendingBehavior({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Logic: calculate category changes based on startDate
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    Map<String, double> currentCategorySpend = {};
    Map<String, double> previousCategorySpend = {};

    for (var sub in subscriptions) {
      if (sub.status == SubscriptionStatus.active || sub.status == SubscriptionStatus.upcoming) {
        final monthlyCost = sub.billingCycle == BillingCycle.monthly ? sub.monthlyPrice : sub.yearlyPrice / 12;
        
        // Current spend includes all active
        currentCategorySpend[sub.category] = (currentCategorySpend[sub.category] ?? 0) + monthlyCost;
        
        // Previous spend includes only those started before 30 days ago
        if (sub.startDate.isBefore(thirtyDaysAgo)) {
          previousCategorySpend[sub.category] = (previousCategorySpend[sub.category] ?? 0) + monthlyCost;
        }
      }
    }

    // Find the largest change
    List<MapEntry<String, double>> changes = [];
    for (var category in currentCategorySpend.keys) {
      final current = currentCategorySpend[category] ?? 0;
      final previous = previousCategorySpend[category] ?? 0;
      if (previous > 0) {
        final percentChange = ((current - previous) / previous) * 100;
        if (percentChange != 0) {
          changes.add(MapEntry(category, percentChange));
        }
      } else if (current > 0) {
        changes.add(MapEntry(category, 100)); // 100% increase (new category)
      }
    }

    // Sort by absolute change
    changes.sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    if (changes.isEmpty) {
      return const SizedBox.shrink(); // No changes to report
    }

    final topChanges = changes.take(2).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_graph_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Spending Behavior',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...topChanges.map((change) {
            final isIncrease = change.value > 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    isIncrease ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    color: isIncrease ? AppColors.error : AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurfaceVariant),
                        children: [
                          TextSpan(
                            text: '${change.key} ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          TextSpan(text: 'spending ${isIncrease ? 'increased' : 'decreased'} by '),
                          TextSpan(
                            text: '${change.value.abs().toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isIncrease ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            'Smart comparison against previous month.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
