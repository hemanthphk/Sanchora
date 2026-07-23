import 'package:flutter/material.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Subscriptions',
                  style: AppTextStyles.bodySecondary,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    totalSubscriptions.toString(),
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSpendingColumn('Monthly', monthlySpending),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _buildSpendingColumn('Yearly', yearlySpending),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingColumn(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}
