import 'package:flutter/material.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';

class SubscriptionEmptyState extends StatelessWidget {
  const SubscriptionEmptyState({
    super.key,
    this.isSearch = false,
    this.onResetFilters,
  });

  final bool isSearch;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearch ? Icons.search_off_rounded : Icons.subscriptions_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearch ? 'No matching subscriptions' : 'No subscriptions yet',
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isSearch
                ? 'Try adjusting your search or filters.'
                : 'Add your first subscription to start tracking.',
            style: AppTextStyles.bodySecondary.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onResetFilters != null) ...[
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onResetFilters,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset Filters'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}