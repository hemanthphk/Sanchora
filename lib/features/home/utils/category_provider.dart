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
    'Entertainment': CategoryStyle(Icons.play_circle_fill_rounded, Color(0xFF4F46E5)),
    'Shopping': CategoryStyle(Icons.shopping_bag_rounded, Color(0xFFFF9500)),
    'Education': CategoryStyle(Icons.school_rounded, Color(0xFF007AFF)),
    'Music': CategoryStyle(Icons.music_note_rounded, Color(0xFFE91E63)),
    'Productivity': CategoryStyle(Icons.work_rounded, Color(0xFF34C759)),
    'AI': CategoryStyle(Icons.smart_toy_rounded, Color(0xFF5E5CE6)),
    'Gaming': CategoryStyle(Icons.sports_esports_rounded, Color(0xFFFF3B30)),
    'Finance': CategoryStyle(Icons.account_balance_wallet_rounded, Color(0xFF32ADE6)),
    'Health': CategoryStyle(Icons.favorite_rounded, Color(0xFFFF2D55)),
    'Streaming': CategoryStyle(Icons.live_tv_rounded, Color(0xFF4F46E5)),
  };

  static CategoryStyle getStyleForCategory(String category) {
    return _styles[category] ?? const CategoryStyle(Icons.category_rounded, Color(0xFF8E8E93));
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
