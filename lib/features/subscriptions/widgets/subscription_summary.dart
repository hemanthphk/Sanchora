import 'package:flutter/material.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';

class SubscriptionSummary extends StatelessWidget {
  const SubscriptionSummary({
    super.key,
    required this.totalSubscriptions,
    required this.monthlySpending,
    required this.yearlySpending,
  });

  final int totalSubscriptions;
  final double monthlySpending;
  final double yearlySpending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total Subscriptions',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$totalSubscriptions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSpendingColumn(theme, 'Monthly Spend', monthlySpending),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _buildSpendingColumn(theme, 'Yearly Spend', yearlySpending),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingColumn(ThemeData theme, String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
