import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';

class AnalyticsCategoryIntelligence extends StatefulWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsCategoryIntelligence({
    super.key,
    required this.subscriptions,
  });

  @override
  State<AnalyticsCategoryIntelligence> createState() => _AnalyticsCategoryIntelligenceState();
}

class _AnalyticsCategoryIntelligenceState extends State<AnalyticsCategoryIntelligence> {
  String? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.subscriptions.isEmpty) return const SizedBox.shrink();

    // Calculations
    Map<String, double> categoryCosts = {};
    Map<String, int> categoryCounts = {};
    
    for (var sub in widget.subscriptions) {
      if (sub.status == SubscriptionStatus.active || sub.status == SubscriptionStatus.upcoming) {
        final monthlyCost = sub.billingCycle == BillingCycle.monthly ? sub.monthlyPrice : sub.yearlyPrice / 12;
        categoryCosts[sub.category] = (categoryCosts[sub.category] ?? 0) + monthlyCost;
        categoryCounts[sub.category] = (categoryCounts[sub.category] ?? 0) + 1;
      }
    }

    if (categoryCosts.isEmpty) return const SizedBox.shrink();

    String largestCategory = categoryCosts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    String leastUsedCategory = categoryCosts.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    String highestValueCategory = categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key; // Most items

    // Fastest growing (mock based on newest subscription)
    widget.subscriptions.sort((a, b) => b.startDate.compareTo(a.startDate));
    String fastestGrowingCategory = widget.subscriptions.first.category;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      clipBehavior: Clip.antiAlias,
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.category_rounded, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Category Intelligence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          _buildCategoryTile(
            title: 'Largest Category',
            category: largestCategory,
            value: CurrencyFormatter.format(categoryCosts[largestCategory]!.round()),
            icon: Icons.pie_chart_rounded,
            iconColor: const Color(0xFF3B82F6), // Blue
            theme: theme,
          ),
          _buildCategoryTile(
            title: 'Fastest Growing',
            category: fastestGrowingCategory,
            value: 'Trending up',
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF10B981), // Green
            theme: theme,
          ),
          _buildCategoryTile(
            title: 'Highest Value',
            category: highestValueCategory,
            value: '${categoryCounts[highestValueCategory]} active',
            icon: Icons.diamond_rounded,
            iconColor: const Color(0xFF8B5CF6), // Purple
            theme: theme,
          ),
          _buildCategoryTile(
            title: 'Least Used',
            category: leastUsedCategory,
            value: CurrencyFormatter.format(categoryCosts[leastUsedCategory]!.round()),
            icon: Icons.trending_down_rounded,
            iconColor: const Color(0xFFF59E0B), // Orange
            theme: theme,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required String category,
    required String value,
    required IconData icon,
    required Color iconColor,
    required ThemeData theme,
    bool isLast = false,
  }) {
    final isExpanded = _expandedCategory == title;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedCategory = isExpanded ? null : title;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category,
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
                  width: 90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _buildExpandedDetails(category, theme),
                )
              : const SizedBox.shrink(),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
      ],
    );
  }

  Widget _buildExpandedDetails(String category, ThemeData theme) {
    final subs = widget.subscriptions.where((s) => s.category == category).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Subscriptions in this category:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...subs.map((sub) {
          final cost = sub.billingCycle == BillingCycle.monthly ? sub.monthlyPrice : sub.yearlyPrice / 12;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sub.name,
                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                ),
                Text(
                  '${CurrencyFormatter.format(cost.round())}/mo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
