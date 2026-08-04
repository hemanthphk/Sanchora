import 'package:flutter/material.dart';
import 'package:sanchora/core/services/currency_service.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';

class SpendingBarData {
  final String label;
  final double amount;
  final double heightFactor;
  final String? tooltipLabel;

  const SpendingBarData({
    required this.label,
    required this.amount,
    required this.heightFactor,
    this.tooltipLabel,
  });
}

class SpendingOverviewCard extends StatefulWidget {
  const SpendingOverviewCard({super.key});

  @override
  State<SpendingOverviewCard> createState() => _SpendingOverviewCardState();
}

class _SpendingOverviewCardState extends State<SpendingOverviewCard> {
  int _selectedIndex = 6; // Default to 'Today'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final spendingMap = SubscriptionService.instance.dashboardSummary.last7DaysSpending;
    final sortedKeys = spendingMap.keys.toList()..sort();
    
    double maxAmount = 0;
    for (var amount in spendingMap.values) {
      if (amount > maxAmount) maxAmount = amount;
    }
    
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final yesterdayMidnight = todayMidnight.subtract(const Duration(days: 1));
    
    final spendingData = sortedKeys.map((date) {
      final amount = spendingMap[date]!;
      final heightFactor = maxAmount == 0 ? 0.01 : amount / maxAmount; // default to 0.01 so bar is slightly visible
      final isToday = date == todayMidnight;
      final isYesterday = date == yesterdayMidnight;
      
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return SpendingBarData(
        label: days[date.weekday - 1],
        amount: amount,
        heightFactor: heightFactor,
        tooltipLabel: isToday ? 'Today' : (isYesterday ? 'Yesterday' : null),
      );
    }).toList();

    final selectedBar = spendingData[_selectedIndex];
    final summary = SubscriptionService.instance.dashboardSummary;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Overview',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'This Month',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyService.instance.format(summary.monthlySpend),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total Spent',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  '${selectedBar.tooltipLabel ?? selectedBar.label} • ${CurrencyService.instance.format(selectedBar.amount)}',
                  key: ValueKey(selectedBar.label),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 115,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: spendingData
                  .asMap()
                  .entries
                  .map((e) => _buildInteractiveBar(context, e.key, e.value))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Highest Spend',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    summary.highestSpendAmount > 0 ? CurrencyService.instance.format(summary.highestSpendAmount) : CurrencyService.instance.format(0),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    summary.highestSpendSubscriptionName.isNotEmpty ? ' • ${summary.highestSpendSubscriptionName}' : ' • None',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveBar(BuildContext context, int index, SpendingBarData data) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                height: 72 * data.heightFactor * (isSelected ? 1.08 : 1.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
