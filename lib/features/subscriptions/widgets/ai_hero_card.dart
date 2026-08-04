import 'package:flutter/material.dart';
import 'package:sanchora/core/services/currency_service.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';

class AiHeroCard extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const AiHeroCard({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final activeCount = SubscriptionService.instance.dashboardSummary.activeSubscriptions;
    
    double potentialSavings = 0;
    final categorySpending = <String, double>{};
    int potentialAnnualSwitchCount = 0;
    
    for (var sub in subscriptions) {
      if (sub.status == SubscriptionStatus.expired) continue;
      
      categorySpending[sub.category] = (categorySpending[sub.category] ?? 0) + sub.monthlyPrice;
      
      if (sub.monthlyPrice >= 300 && sub.billingCycle == BillingCycle.monthly) {
        potentialSavings += (sub.monthlyPrice * 0.2); // Rough estimation of savings if switched to annual
        potentialAnnualSwitchCount++;
      }
    }

    String topCategory = '';
    double maxSpend = 0;
    categorySpending.forEach((category, spend) {
      if (spend > maxSpend) {
        maxSpend = spend;
        topCategory = category;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0A84FF),
              Color(0xFF2563EB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A84FF).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sanchora AI',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Smart Insights',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _getInsightText(activeCount, potentialSavings, topCategory, potentialAnnualSwitchCount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInsightText(int active, double savings, String topCategory, int annualSwitchCount) {
    if (active == 0) {
      return 'You have no active subscriptions. Tap + to add one.';
    }
    if (savings > 50) {
      return 'Potential monthly savings: ${CurrencyService.instance.format(savings)}. Consider switching $annualSwitchCount ${annualSwitchCount == 1 ? 'subscription' : 'subscriptions'} to annual billing.';
    }
    if (topCategory.isNotEmpty && active >= 3) {
      return '$topCategory is your highest spending category. You are actively managing $active subscriptions.';
    }
    return 'You have $active active subscriptions. Your portfolio is well balanced.';
  }
}
