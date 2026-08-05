import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/services/currency_service.dart';
import 'package:sanchora/features/subscriptions/widgets/subscription_icon.dart';

class AnalyticsCostConcentration extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsCostConcentration({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final activeSubs = subscriptions.where((s) => s.status == SubscriptionStatus.active || s.status == SubscriptionStatus.upcoming).toList();
    if (activeSubs.isEmpty) return const SizedBox.shrink();

    // Calculate monthly equivalents
    double totalSpend = 0;
    List<Map<String, dynamic>> subCosts = [];
    
    for (var sub in activeSubs) {
      final cost = sub.billingCycle == BillingCycle.monthly ? sub.monthlyPrice : sub.yearlyPrice / 12;
      totalSpend += cost;
      subCosts.add({'sub': sub, 'cost': cost});
    }

    if (totalSpend == 0) return const SizedBox.shrink();

    // Sort by cost descending
    subCosts.sort((a, b) => (b['cost'] as double).compareTo(a['cost'] as double));

    // Top 20% calculation
    int topCount = (activeSubs.length * 0.2).ceil();
    if (topCount == 0 && activeSubs.isNotEmpty) topCount = 1; // At least one

    double topSpend = 0;
    for (int i = 0; i < topCount; i++) {
      topSpend += subCosts[i]['cost'] as double;
    }

    final double topPercent = (topSpend / totalSpend);
    final int topPercentInt = (topPercent * 100).round();
    final int subPercentInt = ((topCount / activeSubs.length) * 100).round();

    final topContributors = subCosts.take(topCount).toList();

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
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pie_chart_outline_rounded, color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Cost Concentration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: topPercent),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 8,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.error),
                          strokeCap: StrokeCap.round,
                        );
                      },
                    ),
                    Center(
                      child: Text(
                        '$topPercentInt%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top $subPercentInt%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of your total monthly spending',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Biggest Contributors',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...topContributors.map((item) {
            final sub = item['sub'] as SubscriptionModel;
            final cost = item['cost'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SubscriptionIcon(
                    iconIdentifier: sub.iconUrl.isNotEmpty ? sub.iconUrl : sub.name,
                    fallbackName: sub.name,
                    category: sub.category,
                    size: 32,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sub.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${CurrencyService.instance.format(cost.round())}/mo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
