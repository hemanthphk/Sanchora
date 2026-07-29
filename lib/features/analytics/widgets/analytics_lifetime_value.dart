import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';
import 'package:sanchora/features/subscriptions/widgets/subscription_icon.dart';

class AnalyticsLifetimeValue extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsLifetimeValue({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (subscriptions.isEmpty) return const SizedBox.shrink();

    // Calculate lifetime value
    final now = DateTime.now();
    List<Map<String, dynamic>> lifetimeValues = [];

    for (var sub in subscriptions) {
      final days = now.difference(sub.startDate).inDays;
      if (days < 0) continue; // Future start date?
      
      double totalPaid = 0;
      if (sub.billingCycle == BillingCycle.monthly) {
        final months = (days / 30).floor();
        totalPaid = months * sub.monthlyPrice;
      } else {
        final years = (days / 365).floor();
        totalPaid = years * sub.yearlyPrice;
      }

      // Add one payment for the first cycle
      totalPaid += sub.billingCycle == BillingCycle.monthly ? sub.monthlyPrice : sub.yearlyPrice;

      // Format duration
      String duration = '';
      final years = (days / 365).floor();
      final months = ((days % 365) / 30).floor();
      if (years > 0) duration += '$years year${years > 1 ? 's' : ''} ';
      if (months > 0 || years == 0) duration += '$months month${months > 1 ? 's' : ''}';

      lifetimeValues.add({
        'subscription': sub,
        'duration': duration.trim(),
        'totalPaid': totalPaid,
      });
    }

    lifetimeValues.sort((a, b) => (b['totalPaid'] as double).compareTo(a['totalPaid'] as double));

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
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Lifetime Value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...lifetimeValues.map((item) {
            final sub = item['subscription'] as SubscriptionModel;
            final isLast = item == lifetimeValues.last;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      SubscriptionIcon(
                        iconIdentifier: sub.iconUrl.isNotEmpty ? sub.iconUrl : sub.name,
                        fallbackName: sub.name,
                        size: 40,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['duration'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format((item['totalPaid'] as double).round()),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Total paid',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 72,
                    endIndent: 20,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
