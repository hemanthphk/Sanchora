import 'package:flutter/material.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';

enum SortOption {
  nameAsc('Name A–Z'),
  priceLowHigh('Price Low–High'),
  priceHighLow('Price High–Low'),
  renewalDate('Renewal Date');

  final String label;
  const SortOption(this.label);
}

class SubscriptionSortBottomSheet extends StatelessWidget {
  const SubscriptionSortBottomSheet({
    super.key,
    required this.currentSort,
  });

  final SortOption currentSort;

  static Future<SortOption?> show(BuildContext context, SortOption currentSort) {
    return showModalBottomSheet<SortOption>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SubscriptionSortBottomSheet(currentSort: currentSort),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sort By', style: AppTextStyles.sectionTitle),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...SortOption.values.map((option) {
            final isSelected = option == currentSort;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(
                option.label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, option),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
