import 'package:sanchora/features/subscriptions/models/subscription_model.dart';

class AIRecommendation {
  final String title;
  final String description;
  final String type; // e.g. 'warning', 'tip', 'insight'

  const AIRecommendation({
    required this.title,
    required this.description,
    required this.type,
  });
}

class AIRecommendationService {
  static final AIRecommendationService instance = AIRecommendationService._internal();
  AIRecommendationService._internal();

  List<AIRecommendation> generateRecommendations(List<SubscriptionModel> subscriptions) {
    if (subscriptions.isEmpty) {
      return [
        const AIRecommendation(
          title: 'All set',
          description: 'Add your first subscription to get AI insights.',
          type: 'insight',
        )
      ];
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recommendations = <AIRecommendation>[];

    // 1. Renewal within 3 days
    final upcomingRenewals = subscriptions.where((sub) {
      if (sub.status == SubscriptionStatus.expired) return false;
      final target = DateTime(sub.nextRenewalDate.year, sub.nextRenewalDate.month, sub.nextRenewalDate.day);
      final diff = target.difference(today).inDays;
      return diff >= 0 && diff <= 3;
    }).toList();

    if (upcomingRenewals.isNotEmpty) {
      recommendations.add(AIRecommendation(
        title: 'Upcoming Renewal',
        description: '${upcomingRenewals.first.name} renews in ${upcomingRenewals.first.nextRenewalDate.difference(today).inDays} days.',
        type: 'warning',
      ));
    }

    // 2. Highest monthly spending
    SubscriptionModel? highestSub;
    double highestPrice = 0;
    for (var sub in subscriptions) {
      if (sub.status != SubscriptionStatus.expired) {
        if (sub.monthlyPrice > highestPrice) {
          highestPrice = sub.monthlyPrice;
          highestSub = sub;
        }
      }
    }
    
    if (highestSub != null && highestPrice > 0) {
      recommendations.add(AIRecommendation(
        title: 'Highest Subscription Cost',
        description: 'Your highest monthly subscription is ${highestSub.name}.',
        type: 'insight',
      ));
      
      // Tip for annual billing
      if (highestSub.billingCycle == BillingCycle.monthly) {
        recommendations.add(AIRecommendation(
          title: 'Potential Savings',
          description: '${highestSub.name} annual plan could save money.',
          type: 'tip',
        ));
      }
    }

    // 3. Duplicate categories
    final Map<String, int> categoryCounts = {};
    for (var sub in subscriptions) {
      if (sub.status != SubscriptionStatus.expired) {
        categoryCounts[sub.category] = (categoryCounts[sub.category] ?? 0) + 1;
      }
    }
    
    for (var entry in categoryCounts.entries) {
      if (entry.value >= 3) {
        recommendations.add(AIRecommendation(
          title: 'Category Insight',
          description: 'You have ${entry.value} ${entry.key} subscriptions.',
          type: 'insight',
        ));
        break; // Only show one duplicate category warning
      }
    }

    // 4. Free trial ending (mock logic: check if name contains 'trial' or price is 0)
    final freeTrials = subscriptions.where((sub) => sub.status != SubscriptionStatus.expired && (sub.name.toLowerCase().contains('trial') || sub.currentPrice == 0)).toList();
    if (freeTrials.isNotEmpty) {
      recommendations.add(AIRecommendation(
        title: 'Free Trial Ending',
        description: '${freeTrials.first.name} trial might be ending soon. Review it to avoid charges.',
        type: 'warning',
      ));
    }

    // 5. No renewals
    if (upcomingRenewals.isEmpty) {
      recommendations.add(const AIRecommendation(
        title: 'Peace of Mind',
        description: 'No renewals in the next 3 days. You\'re all set.',
        type: 'insight',
      ));
    }
    
    return recommendations;
  }
}
