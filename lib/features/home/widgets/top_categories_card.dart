import 'package:flutter/material.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';
import 'package:sanchora/features/categories/screens/top_categories_screen.dart';
import 'package:sanchora/features/subscriptions/screens/subscriptions_screen.dart';
import 'package:sanchora/features/home/utils/category_provider.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';

class TopCategoriesCard extends StatefulWidget {
  const TopCategoriesCard({super.key});

  @override
  State<TopCategoriesCard> createState() => _TopCategoriesCardState();
}

class _TopCategoriesCardState extends State<TopCategoriesCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: SubscriptionService.instance,
      builder: (context, _) {
        final allCategories = CategoryProvider.getCategorySummaries(
          subscriptions: SubscriptionService.instance.subscriptions,
        );
        final topCategories = allCategories.take(3).toList();

        return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Categories',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TopCategoriesScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    'View All →',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: topCategories.asMap().entries.map((e) {
                final isLast = e.key == topCategories.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 8),
                    child: _buildCategoryCard(context, e.key, e.value),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, int index, CategorySummary data) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 320 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: AnimatedScale(
        scale: isSelected ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            Future.delayed(const Duration(milliseconds: 150), () {
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SubscriptionsScreen(categoryFilter: data.name),
                ),
              );
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? data.color.withValues(alpha: 0.5) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: data.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        data.icon,
                        size: 17,
                        color: data.color,
                      ),
                    ),
                    Text(
                      data.percentage,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: data.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.name,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(data.amount),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: data.share.clamp(0.0, 1.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: data.color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
