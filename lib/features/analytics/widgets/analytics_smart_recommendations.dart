import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';

class AnalyticsSmartRecommendations extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsSmartRecommendations({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (subscriptions.isEmpty) return const SizedBox.shrink();

    List<Widget> recommendations = [];

    // Rule 1: Annual Savings Opportunity
    for (var sub in subscriptions) {
      if (sub.status == SubscriptionStatus.active && sub.billingCycle == BillingCycle.monthly) {
        final yearlyCost = sub.yearlyPrice;
        final monthlyCostTotal = sub.monthlyPrice * 12;
        if (yearlyCost < monthlyCostTotal && yearlyCost > 0) {
          final savings = monthlyCostTotal - yearlyCost;
          if (savings > 0) {
            recommendations.add(
              _RecommendationCard(
                title: 'Switch to Annual',
                description: 'Upgrade ${sub.name} to an annual plan and save ${CurrencyFormatter.format(savings.round())} every year.',
                icon: Icons.savings_rounded,
                color: AppColors.success,
                theme: theme,
              ),
            );
            break; // Only show one of these to keep UI clean
          }
        }
      }
    }

    // Rule 2: Overlapping Categories
    Map<String, List<SubscriptionModel>> categories = {};
    for (var sub in subscriptions) {
      if (sub.status == SubscriptionStatus.active) {
        categories[sub.category] = (categories[sub.category] ?? [])..add(sub);
      }
    }

    for (var entry in categories.entries) {
      if (entry.value.length > 1) {
        final names = entry.value.map((s) => s.name).join(' and ');
        recommendations.add(
          _RecommendationCard(
            title: 'Category Overlap',
            description: 'You are subscribed to $names. Consider if you need both ${entry.key} services.',
            icon: Icons.flip_to_front_rounded,
            color: AppColors.warning,
            theme: theme,
          ),
        );
        break; // Only show one
      }
    }

    // Rule 3: Unused detection mock (just base it on oldest active sub)
    if (subscriptions.isNotEmpty && recommendations.length < 3) {
      final sortedByDate = List<SubscriptionModel>.from(subscriptions)..sort((a, b) => a.startDate.compareTo(b.startDate));
      final oldest = sortedByDate.first;
      if (DateTime.now().difference(oldest.startDate).inDays > 365) {
        recommendations.add(
          _RecommendationCard(
            title: 'Longevity Check',
            description: 'You\'ve had ${oldest.name} for over a year. Make sure you\'re still actively using it.',
            icon: Icons.history_rounded,
            color: AppColors.primary,
            theme: theme,
          ),
        );
      }
    }

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Smart Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 154,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => recommendations[index],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _RecommendationCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
