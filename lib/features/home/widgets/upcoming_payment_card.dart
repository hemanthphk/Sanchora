import 'package:flutter/material.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';
import 'package:sanchora/core/widgets/sanchora_card.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/features/subscriptions/presentation/pages/view_subscription_page.dart';
import 'package:sanchora/features/subscriptions/widgets/subscription_icon.dart';

/// A compact, premium card displaying upcoming payment renewal details.
/// Optimized specifically for timeline views: features App Logo, Name, Renewal Status,
/// Price, and Chevron without unnecessary metadata.
/// Designed according to Apple Wallet + Stripe + Linear design language.
class UpcomingPaymentCard extends StatelessWidget {
  const UpcomingPaymentCard({
    super.key,
    required this.subscription,
    this.onTap,
    this.aiTip,
  });

  final SubscriptionModel subscription;
  final VoidCallback? onTap;
  final String? aiTip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = _getRenewalStatusInfo(subscription, theme);

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => _navigateToViewDetails(context),
          borderRadius: BorderRadius.circular(20),
          child: SanchoraCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            statusInfo.text,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: statusInfo.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${CurrencyFormatter.format(subscription.currentPrice)}/${subscription.billingCycle == BillingCycle.monthly ? 'month' : 'year'}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
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
    );
  }

  Widget _buildAppIcon(ThemeData theme) {
    return SubscriptionIcon(
      iconIdentifier: subscription.iconUrl,
      fallbackName: subscription.name,
      size: 42,
      borderRadius: 12,
      backgroundColor: theme.colorScheme.surface,
      textColor: theme.colorScheme.primary,
      textStyle: AppTextStyles.sectionTitle.copyWith(
        fontSize: 18,
        color: theme.colorScheme.primary,
      ),
      border: Border.all(color: theme.dividerColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  ({String text, Color color}) _getRenewalStatusInfo(SubscriptionModel sub, ThemeData theme) {
    if (sub.status == SubscriptionStatus.expired) {
      return (
        text: 'Expired',
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(sub.nextRenewalDate.year, sub.nextRenewalDate.month, sub.nextRenewalDate.day);
    final diff = target.difference(today).inDays;

    if (diff <= 0) {
      return (
        text: 'Renews Today',
        color: AppColors.error, // Red
      );
    } else if (diff == 1) {
      return (
        text: 'Renews Tomorrow',
        color: AppColors.warning, // Orange
      );
    } else if (diff <= 3) {
      return (
        text: 'Renews in $diff Days',
        color: AppColors.warning, // Orange
      );
    } else {
      return (
        text: 'Renews in $diff Days',
        color: theme.colorScheme.primary, // Blue
      );
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
}
