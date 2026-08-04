import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';
import 'package:sanchora/core/services/currency_service.dart';

class ProfileStatisticsCard extends StatelessWidget {
  const ProfileStatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    return ListenableBuilder(
      listenable: subscriptionService,
      builder: (context, _) {
        final activeSubs = subscriptionService.dashboardSummary.activeSubscriptions;
        final totalSpent = CurrencyService.instance.format(subscriptionService.dashboardSummary.lifetimeSpend, compact: true);
        final totalSaved = CurrencyService.instance.format(subscriptionService.dashboardSummary.totalSaved, compact: true);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildColumn(
                  context,
                  icon: Icons.subscriptions_rounded,
                  iconColor: const Color(0xFF2563EB),
                  value: activeSubs.toString(),
                  label: 'Active Subs',
                ),
              ),
              _buildDivider(borderColor, isDark),
              Expanded(
                child: _buildColumn(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFF10B981),
                  value: totalSpent,
                  label: 'Spent',
                ),
              ),
              _buildDivider(borderColor, isDark),
              Expanded(
                child: _buildColumn(
                  context,
                  icon: Icons.savings_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  value: totalSaved,
                  label: 'Saved',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColumn(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(Color borderColor, bool isDark) {
    return Container(
      width: 1,
      height: 60,
      color: borderColor.withValues(alpha: isDark ? 0.3 : 0.6),
    );
  }
}
