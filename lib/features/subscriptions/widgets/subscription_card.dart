import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';
import 'package:sanchora/core/services/currency_service.dart';
import '../models/subscription_model.dart';
import 'subscription_icon.dart';
import '../presentation/pages/view_subscription_page.dart';
import 'package:sanchora/features/add_subscription/presentation/pages/add_subscription_page.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
    this.aiTip,
  });

  final SubscriptionModel subscription;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? aiTip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(subscription.id),
        startActionPane: ActionPane(
          extentRatio: 0.22,
          motion: const BehindMotion(),
          children: [
            CustomSlidableAction(
              onPressed: (_) => onEdit != null ? onEdit!() : _navigateToEdit(context),
              padding: const EdgeInsets.only(right: 12),
              backgroundColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, color: theme.colorScheme.primary, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      'Edit',
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          extentRatio: 0.22,
          motion: const BehindMotion(),
          children: [
            CustomSlidableAction(
              onPressed: (_) => _showDeleteDialog(context),
              padding: const EdgeInsets.only(left: 12),
              backgroundColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE57373).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: Color(0xFFE57373), size: 22),
                    const SizedBox(height: 4),
                    const Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFFE57373), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onViewDetails ?? () => _navigateToViewDetails(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAppIcon(theme),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subscription.category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _getCategoryColor(theme, subscription.category),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${CurrencyService.instance.format(subscription.currentPrice)}/${subscription.billingCycle == BillingCycle.monthly ? 'mo' : 'yr'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildRenewalCountdown(theme),
                        ],
                      ),
                    ],
                  ),
                  if (aiTip != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.success),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              aiTip!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon(ThemeData theme) {
    return SubscriptionIcon(
      iconIdentifier: subscription.iconUrl,
      fallbackName: subscription.name,
      size: 44,
      borderRadius: 12,
      backgroundColor: theme.colorScheme.surface,
      textColor: theme.colorScheme.primary,
      textStyle: AppTextStyles.sectionTitle.copyWith(
        fontSize: 18,
        color: theme.colorScheme.primary,
      ),
      border: Border.all(color: theme.dividerColor),
    );
  }

  Widget _buildRenewalCountdown(ThemeData theme) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(subscription.nextRenewalDate.year, subscription.nextRenewalDate.month, subscription.nextRenewalDate.day);
    final diff = target.difference(today).inDays;

    String text;
    Color color;

    if (subscription.status == SubscriptionStatus.expired) {
      text = 'Expired';
      color = AppColors.error;
    } else if (diff < 0) {
      text = 'Overdue';
      color = AppColors.error;
    } else if (diff == 0) {
      text = 'Renews today';
      color = AppColors.warning;
    } else if (diff == 1) {
      text = 'Renews tomorrow';
      color = AppColors.warning;
    } else if (diff <= 7) {
      text = 'Renews in $diff days';
      color = theme.colorScheme.onSurfaceVariant;
    } else {
      text = 'Renews ${DateFormat('dd MMM').format(subscription.nextRenewalDate)}';
      color = theme.colorScheme.onSurfaceVariant;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Color _getCategoryColor(ThemeData theme, String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return Colors.purple;
      case 'productivity':
        return Colors.blue;
      case 'utility':
        return Colors.orange;
      case 'education':
        return Colors.teal;
      default:
        return theme.colorScheme.primary;
    }
  }

  void _navigateToViewDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewSubscriptionPage(subscription: subscription),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSubscriptionPage(subscriptionToEdit: subscription),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Subscription', style: AppTextStyles.sectionTitle.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        content: Text('Are you sure you want to delete ${subscription.name}?', style: AppTextStyles.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) onDelete!();
            },
            child: Text('Delete', style: AppTextStyles.body.copyWith(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
