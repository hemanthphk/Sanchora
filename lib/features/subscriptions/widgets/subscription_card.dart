import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';
import 'package:sanchora/core/widgets/sanchora_card.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';
import '../models/subscription_model.dart';
import 'subscription_icon.dart';
import '../presentation/pages/view_subscription_page.dart';
import 'package:sanchora/features/add_subscription/presentation/pages/add_subscription_page.dart';

/// Command Center management dashboard card for Subscriptions.
/// Designed according to Apple + Stripe + Linear design language.
/// Features always-visible action pills [View], [Edit], [Delete] and compact ~92px layout.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
  });

  final SubscriptionModel subscription;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetails ?? () => _navigateToViewDetails(context),
          borderRadius: BorderRadius.circular(18),
          child: SanchoraCard(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppIcon(theme),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.name,
                            style: TextStyle(
                              fontSize: 15.5,
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
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatusBadge(theme),
                        const SizedBox(height: 4),
                        Text(
                          '${CurrencyFormatter.format(subscription.currentPrice)}/${subscription.billingCycle == BillingCycle.monthly ? 'mo' : 'yr'}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Renews ${DateFormat('dd MMM').format(subscription.nextRenewalDate)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionPill(
                        theme,
                        Icons.remove_red_eye_outlined,
                        'View',
                        onViewDetails ?? () => _navigateToViewDetails(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionPill(
                        theme,
                        Icons.edit_outlined,
                        'Edit',
                        onEdit ?? () => _navigateToEdit(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionPill(
                        theme,
                        Icons.delete_outline,
                        'Delete',
                        () => _showDeleteDialog(context),
                        isDestructive: true,
                      ),
                    ),
                  ],
                ),
              ],
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
      size: 40,
      borderRadius: 10,
      backgroundColor: theme.colorScheme.surface,
      textColor: theme.colorScheme.primary,
      textStyle: AppTextStyles.sectionTitle.copyWith(
        fontSize: 17,
        color: theme.colorScheme.primary,
      ),
      border: Border.all(color: theme.dividerColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    Color bgColor;
    Color textColor;
    String text;

    switch (subscription.status) {
      case SubscriptionStatus.active:
        bgColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
        text = 'Active';
        break;
      case SubscriptionStatus.upcoming:
        bgColor = AppColors.warning.withValues(alpha: 0.12);
        textColor = AppColors.warning;
        text = 'Upcoming';
        break;
      case SubscriptionStatus.expired:
        bgColor = AppColors.error.withValues(alpha: 0.12);
        textColor = AppColors.error;
        text = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionPill(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;
    final bgColor = isDestructive
        ? theme.colorScheme.error.withValues(alpha: 0.08)
        : theme.colorScheme.primary.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
