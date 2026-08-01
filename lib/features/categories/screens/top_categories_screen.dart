import 'package:flutter/material.dart';
import 'package:sanchora/core/widgets/app_header.dart';
import 'package:sanchora/features/home/utils/category_provider.dart';
import 'package:sanchora/features/subscriptions/screens/subscriptions_screen.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';

class TopCategoriesScreen extends StatelessWidget {
  const TopCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Top Categories',
              leading: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: SubscriptionService.instance,
                builder: (context, _) {
                  final categories = CategoryProvider.getCategorySummaries(
                    subscriptions: SubscriptionService.instance.subscriptions,
                  );

                  if (categories.isEmpty) {
                    return Center(
                      child: Text(
                        'No categories found.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final data = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCategoryItem(context, data),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategorySummary data) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SubscriptionsScreen(categoryFilter: data.name),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                data.icon,
                color: data.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.count} ${data.count == 1 ? 'Subscription' : 'Subscriptions'}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
