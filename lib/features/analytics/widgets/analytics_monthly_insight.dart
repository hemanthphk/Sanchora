import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';

class AnalyticsMonthlyInsight extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsMonthlyInsight({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) return const SizedBox.shrink();

    // Generate insights
    List<Map<String, dynamic>> insights = [];

    // Insight 1: Most expensive overall
    final sortedByCost = List<SubscriptionModel>.from(subscriptions)
      ..sort((a, b) {
        final aCost = a.billingCycle == BillingCycle.monthly ? a.monthlyPrice : a.yearlyPrice / 12;
        final bCost = b.billingCycle == BillingCycle.monthly ? b.monthlyPrice : b.yearlyPrice / 12;
        return bCost.compareTo(aCost);
      });
    if (sortedByCost.isNotEmpty) {
      final sub = sortedByCost.first;
      final cost = sub.billingCycle == BillingCycle.monthly ? sub.monthlyPrice : sub.yearlyPrice / 12;
      insights.add({
        'title': 'Highest Drain',
        'desc': '${sub.name} is your most expensive service at ${CurrencyFormatter.format(cost.round())}/mo.',
        'icon': Icons.diamond_rounded,
        'colors': [const Color(0xFF8A2387), const Color(0xFFE94057), const Color(0xFFF27121)],
      });
    }

    // Insight 2: Longest active
    final sortedByDate = List<SubscriptionModel>.from(subscriptions)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (sortedByDate.isNotEmpty) {
      final sub = sortedByDate.first;
      final years = (DateTime.now().difference(sub.startDate).inDays / 365).floor();
      if (years >= 1) {
        insights.add({
          'title': 'True Loyal',
          'desc': 'You have been subscribed to ${sub.name} for over $years years.',
          'icon': Icons.workspace_premium_rounded,
          'colors': [const Color(0xFF11998e), const Color(0xFF38ef7d)],
        });
      }
    }

    // Insight 3: Upcoming cluster
    int upcomingCount = subscriptions.where((s) {
      if (s.status != SubscriptionStatus.active) return false;
      return s.nextRenewalDate.difference(DateTime.now()).inDays <= 7;
    }).length;

    if (upcomingCount > 1) {
      insights.add({
        'title': 'Busy Week Ahead',
        'desc': 'You have $upcomingCount renewals scheduled for the next 7 days. Make sure funds are ready.',
        'icon': Icons.warning_rounded,
        'colors': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
      });
    }

    if (insights.isEmpty) {
      insights.add({
        'title': 'All Clear',
        'desc': 'No major insights to report this week. Your subscriptions look healthy.',
        'icon': Icons.check_circle_outline_rounded,
        'colors': [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
      });
    }

    // Pick one deterministically based on day of week to simulate rotation
    final int insightIndex = DateTime.now().weekday % insights.length;
    final selectedInsight = insights[insightIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: selectedInsight['colors'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (selectedInsight['colors'] as List<Color>).last.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(selectedInsight['icon'] as IconData, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insight: ${selectedInsight['title']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedInsight['desc'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
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
