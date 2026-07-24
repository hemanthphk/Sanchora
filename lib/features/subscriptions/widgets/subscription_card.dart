import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';
import 'package:sanchora/core/widgets/sanchora_card.dart';
import '../models/subscription_model.dart';

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
      padding: const EdgeInsets.only(bottom: 16),
      child: SanchoraCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAppIcon(theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.name,
                        style: AppTextStyles.sectionTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subscription.category,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  'Price',
                  '\$${subscription.currentPrice.toStringAsFixed(2)}',
                  '/${subscription.billingCycle == BillingCycle.monthly ? 'mo' : 'yr'}',
                ),
                _buildInfoItem(
                  'Next Renewal',
                  DateFormat('MMM dd, yyyy').format(subscription.nextRenewalDate),
                  '',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (subscription.hasReminder) ...[
                      Icon(Icons.notifications_active_outlined, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('Reminder On', style: AppTextStyles.caption.copyWith(color: theme.colorScheme.primary)),
                    ] else ...[
                      Icon(Icons.notifications_off_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text('No Reminder', style: AppTextStyles.caption),
                    ]
                  ],
                ),
                Row(
                  children: [
                    _buildActionButton(theme, Icons.remove_red_eye_outlined, 'View', onViewDetails),
                    const SizedBox(width: 8),
                    _buildActionButton(theme, Icons.edit_outlined, 'Edit', onEdit),
                    const SizedBox(width: 8),
                    _buildActionButton(theme, Icons.delete_outline, 'Delete', () {
                      _showDeleteDialog(context);
                    }, isDestructive: true),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(ThemeData theme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          subscription.name.isNotEmpty ? subscription.name[0].toUpperCase() : '?',
          style: AppTextStyles.sectionTitle.copyWith(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;

    switch (subscription.status) {
      case SubscriptionStatus.active:
        bgColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        text = 'Active';
        break;
      case SubscriptionStatus.upcoming:
        bgColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        text = 'Upcoming';
        break;
      case SubscriptionStatus.expired:
        bgColor = AppColors.error.withValues(alpha: 0.15);
        textColor = AppColors.error;
        text = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTextStyles.cardTitle,
            ),
            if (suffix.isNotEmpty)
              Text(
                suffix,
                style: AppTextStyles.bodySecondary,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(ThemeData theme, IconData icon, String tooltip, VoidCallback? onTap, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            icon,
            size: 20,
            color: isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: Text('Are you sure you want to delete ${subscription.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
