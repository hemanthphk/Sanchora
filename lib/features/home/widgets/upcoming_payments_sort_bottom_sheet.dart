import 'package:flutter/material.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';

enum UpcomingSortOption {
  nearestFirst('Nearest First (Default)'),
  highestAmount('Highest Amount'),
  lowestAmount('Lowest Amount'),
  alphabetical('Alphabetical');

  final String label;
  const UpcomingSortOption(this.label);
}

class UpcomingPaymentsSortBottomSheet extends StatelessWidget {
  const UpcomingPaymentsSortBottomSheet({
    super.key,
    required this.currentSort,
  });

  final UpcomingSortOption currentSort;

  static Future<UpcomingSortOption?> show(BuildContext context, UpcomingSortOption currentSort) {
    return showModalBottomSheet<UpcomingSortOption>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => UpcomingPaymentsSortBottomSheet(currentSort: currentSort),
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
                Text('Sort By', style: AppTextStyles.sectionTitle.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...UpcomingSortOption.values.map((option) {
            final isSelected = option == currentSort;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(
                option.label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
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
