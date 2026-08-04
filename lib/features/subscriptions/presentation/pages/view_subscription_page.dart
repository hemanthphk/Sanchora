import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/services/currency_service.dart';
import 'package:sanchora/core/widgets/sanchora_card.dart';
import 'package:sanchora/features/add_subscription/presentation/pages/add_subscription_page.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';
import '../../models/subscription_model.dart';
import '../../widgets/subscription_icon.dart';

/// Full-screen navigation page for displaying complete subscription details.
/// Designed to be future-ready for real logos, cloud sync, OCR, and AI Insights.
class ViewSubscriptionPage extends StatefulWidget {
  const ViewSubscriptionPage({
    super.key,
    required this.subscription,
  });

  final SubscriptionModel subscription;

  @override
  State<ViewSubscriptionPage> createState() => _ViewSubscriptionPageState();
}

class _ViewSubscriptionPageState extends State<ViewSubscriptionPage> {
  late SubscriptionModel _subscription;

  SubscriptionModel get subscription => _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.subscription;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          'Subscription Details',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTopCard(theme),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildInformationCard(context, theme),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildSummaryCard(theme),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildButtons(context, theme),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(ThemeData theme) {
    return SanchoraCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          SubscriptionIcon(
            iconIdentifier: subscription.iconUrl,
            fallbackName: subscription.name,
            size: 56,
            borderRadius: 14,
            backgroundColor: theme.colorScheme.surface,
            textColor: theme.colorScheme.primary,
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subscription.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subscription.category,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildStatusChip(theme, subscription.status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, SubscriptionStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
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
      case SubscriptionStatus.cancelled:
        bgColor = AppColors.error.withValues(alpha: 0.15); // Or a specific cancelled color
        textColor = AppColors.error;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildInformationCard(BuildContext context, ThemeData theme) {
    final priceSuffix = subscription.billingCycle == BillingCycle.monthly ? '/ month' : '/ year';
    final priceFormatted = '${CurrencyService.instance.format(subscription.currentPrice)} $priceSuffix';
    final cycleFormatted = subscription.billingCycle == BillingCycle.monthly ? 'Monthly' : 'Yearly';
    final startDateFormatted = DateFormat('dd MMM yyyy').format(_calculateStartDate(subscription.nextRenewalDate, subscription.billingCycle));
    final renewalDateFormatted = DateFormat('dd MMM yyyy').format(subscription.nextRenewalDate);
    final reminderFormatted = subscription.hasReminder ? 'Enabled' : 'Disabled';
    final reminderColor = subscription.hasReminder ? AppColors.success : Theme.of(context).colorScheme.onSurfaceVariant;
    final notesFormatted = subscription.notes != null && subscription.notes!.trim().isNotEmpty
        ? subscription.notes!.trim()
        : 'No notes added';

    return SanchoraCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(context, theme, 'Price', priceFormatted),
          _buildDivider(theme),
          _buildInfoRow(context, theme, 'Billing Cycle', cycleFormatted),
          _buildDivider(theme),
          _buildInfoRow(context, theme, 'Start Date', startDateFormatted),
          _buildDivider(theme),
          _buildInfoRow(context, theme, 'Renewal Date', renewalDateFormatted),
          _buildDivider(theme),
          _buildInfoRow(context, theme, 'Reminder', reminderFormatted, valueColor: reminderColor),
          _buildDivider(theme),
          _buildInfoRow(context, theme, 'Notes', notesFormatted),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, ThemeData theme, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ).copyWith(
                color: valueColor ?? Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final renewalDay = DateTime(
      subscription.nextRenewalDate.year,
      subscription.nextRenewalDate.month,
      subscription.nextRenewalDate.day,
    );
    final daysDifference = renewalDay.difference(today).inDays;

    String valueText;
    Color valueColor;

    if (daysDifference > 1) {
      valueText = 'Renews in $daysDifference Days';
      valueColor = theme.colorScheme.primary;
    } else if (daysDifference == 1) {
      valueText = 'Renews Tomorrow';
      valueColor = theme.colorScheme.primary;
    } else if (daysDifference == 0) {
      valueText = 'Renews Today';
      valueColor = AppColors.warning;
    } else {
      valueText = 'Expired';
      valueColor = AppColors.error;
    }

    return SanchoraCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Next Renewal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              valueText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            child: Text(
              'Back',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _navigateToEdit(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Edit Subscription',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  DateTime _calculateStartDate(DateTime renewalDate, BillingCycle cycle) {
    if (cycle == BillingCycle.monthly) {
      return DateTime(renewalDate.year, renewalDate.month - 1, renewalDate.day);
    } else {
      return DateTime(renewalDate.year - 1, renewalDate.month, renewalDate.day);
    }
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSubscriptionPage(subscriptionToEdit: _subscription),
      ),
    );
    if (result != null && result is SubscriptionModel && mounted) {
      setState(() {
        _subscription = result;
      });
    } else if (result == true && mounted) {
      final updated = SubscriptionService.instance.subscriptions.firstWhere(
        (s) => s.id == _subscription.id,
        orElse: () => _subscription,
      );
      setState(() {
        _subscription = updated;
      });
    }
  }
}
