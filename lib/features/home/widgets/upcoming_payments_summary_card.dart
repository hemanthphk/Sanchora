import 'package:flutter/material.dart';

class UpcomingPaymentsSummaryCard extends StatelessWidget {
  const UpcomingPaymentsSummaryCard({
    super.key,
    required this.todayCount,
    required this.thisWeekCount,
    required this.thisMonthCount,
  });

  final int todayCount;
  final int thisWeekCount;
  final int thisMonthCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(theme, 'Renewing Today', todayCount),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(theme, 'This Week', thisWeekCount),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(theme, 'This Month', thisMonthCount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
