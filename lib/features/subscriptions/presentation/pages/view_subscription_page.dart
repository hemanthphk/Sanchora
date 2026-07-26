import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopCard(theme),
              const SizedBox(height: 20),
              _buildInformationCard(theme),
              const SizedBox(height: 20),
              _buildSummaryCard(theme),
              const SizedBox(height: 32),
              _buildButtons(context, theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(ThemeData theme) {
    return SanchoraCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SubscriptionIcon(
            iconIdentifier: subscription.iconUrl,
            fallbackName: subscription.name,
            size: 72,
            borderRadius: 18,
            backgroundColor: theme.colorScheme.surface,
            textColor: theme.colorScheme.primary,
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subscription.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subscription.category,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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

  Widget _buildInformationCard(ThemeData theme) {
    final priceSuffix = subscription.billingCycle == BillingCycle.monthly ? '/ month' : '/ year';
    final priceFormatted = '${CurrencyFormatter.format(subscription.currentPrice)} $priceSuffix';
    final cycleFormatted = subscription.billingCycle == BillingCycle.monthly ? 'Monthly' : 'Yearly';
    final startDateFormatted = DateFormat('dd MMM yyyy').format(_calculateStartDate(subscription.nextRenewalDate, subscription.billingCycle));
    final renewalDateFormatted = DateFormat('dd MMM yyyy').format(subscription.nextRenewalDate);
    final reminderFormatted = subscription.hasReminder ? 'Enabled' : 'Disabled';
    final notesFormatted = subscription.notes != null && subscription.notes!.trim().isNotEmpty
        ? subscription.notes!.trim()
        : 'No notes';

    return SanchoraCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(theme, 'Price', priceFormatted),
          _buildDivider(theme),
          _buildInfoRow(theme, 'Billing Cycle', cycleFormatted),
          _buildDivider(theme),
          _buildInfoRow(theme, 'Start Date', startDateFormatted),
          _buildDivider(theme),
          _buildInfoRow(theme, 'Renewal Date', renewalDateFormatted),
          _buildDivider(theme),
          _buildInfoRow(theme, 'Reminder', reminderFormatted),
          _buildDivider(theme),
          _buildInfoRow(theme, 'Notes', notesFormatted, isNotes: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value, {bool isNotes = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: isNotes
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
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

    return SanchoraCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Renewal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          if (daysDifference > 0) ...[
            Text(
              'Next renewal in',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$daysDifference ${daysDifference == 1 ? 'Day' : 'Days'}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ] else if (daysDifference == 0) ...[
            Text(
              'Renew today',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
          ] else ...[
            Text(
              'Expired',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navigateToEdit(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Edit Subscription',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            child: Text(
              'Back',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
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
