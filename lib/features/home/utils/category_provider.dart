import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';

class CategorySummary {
  final String name;
  final double amount;
  final String percentage;
  final double share;
  final IconData icon;
  final Color color;
  final int count;

  const CategorySummary({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.share,
    required this.icon,
    required this.color,
    required this.count,
  });
}

class CategoryProvider {
  static const Map<String, CategoryStyle> _styles = {
    'Streaming': CategoryStyle(Icons.play_circle_outline_rounded, Color(0xFFEF4444)),
    'Music': CategoryStyle(Icons.music_note_rounded, Color(0xFF10B981)),
    'Gaming': CategoryStyle(Icons.sports_esports_outlined, Color(0xFF8B5CF6)),
    'Cloud Storage': CategoryStyle(Icons.cloud_outlined, Color(0xFF3B82F6)),
    'Design': CategoryStyle(Icons.palette_outlined, Color(0xFFF59E0B)),
    'Productivity': CategoryStyle(Icons.work_outline_rounded, Color(0xFF0EA5E9)),
    'Education': CategoryStyle(Icons.school_outlined, Color(0xFF14B8A6)),
    'Finance': CategoryStyle(Icons.account_balance_wallet_outlined, Color(0xFFF59E0B)),
    'Shopping': CategoryStyle(Icons.shopping_bag_outlined, Color(0xFFEC4899)),
    'Food': CategoryStyle(Icons.restaurant_outlined, Color(0xFFF97316)),
    'Fitness': CategoryStyle(Icons.fitness_center_outlined, Color(0xFF10B981)),
    'Security': CategoryStyle(Icons.security_outlined, Color(0xFF64748B)),
    'Other': CategoryStyle(Icons.inventory_2_outlined, Color(0xFF8E8E93)),
  };

  static CategoryStyle getStyleForCategory(String category) {
    return _styles[category] ?? const CategoryStyle(Icons.inventory_2_outlined, Color(0xFF8E8E93));
  }

  static List<CategorySummary> getCategorySummaries({
    required List<SubscriptionModel> subscriptions,
  }) {
    if (subscriptions.isEmpty) return [];

    final Map<String, double> categoryAmounts = {};
    final Map<String, int> categoryCounts = {};
    double totalAmount = 0;

    for (final sub in subscriptions) {
      if (sub.status == SubscriptionStatus.expired) continue;
      final category = sub.category;
      
      // Calculate normalized monthly price
      final double normalizedMonthlyPrice = sub.billingCycle == BillingCycle.monthly 
          ? sub.currentPrice 
          : sub.currentPrice / 12;

      categoryAmounts[category] = (categoryAmounts[category] ?? 0) + normalizedMonthlyPrice;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      totalAmount += normalizedMonthlyPrice;
    }

    final summaries = categoryAmounts.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final count = categoryCounts[category] ?? 0;
      final share = totalAmount > 0 ? amount / totalAmount : 0.0;
      final percentage = '${(share * 100).round()}%';
      final style = getStyleForCategory(category);

      return CategorySummary(
        name: category,
        amount: amount,
        percentage: percentage,
        share: share,
        icon: style.icon,
        color: style.color,
        count: count,
      );
    }).toList();

    // Sort by number of subscriptions (desc), then alphabetically
    summaries.sort((a, b) {
      final countComparison = b.count.compareTo(a.count);
      if (countComparison != 0) return countComparison;
      return a.name.compareTo(b.name);
    });

    return summaries;
  }
}

class CategoryStyle {
  final IconData icon;
  final Color color;

  const CategoryStyle(this.icon, this.color);
}
