import 'package:flutter/material.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';

class AnalyticsEmptyState extends StatelessWidget {
  const AnalyticsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_rounded,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Unlock Powerful Insights',
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Add subscriptions to discover spending trends, efficiency analysis, and AI-powered recommendations.',
            style: AppTextStyles.bodySecondary.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Navigation to add subscription handled by main tab bar,
              // or we can invoke a callback here. For now, rely on bottom nav.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Add Subscription',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
