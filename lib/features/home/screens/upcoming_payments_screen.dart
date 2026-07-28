import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';
import 'package:sanchora/core/utils/currency_formatter.dart';
import '../widgets/upcoming_payment_card.dart';
import '../widgets/upcoming_payments_empty_state.dart';

class TimelineSection {
  final String title;
  final List<SubscriptionModel> subscriptions;
  const TimelineSection(this.title, this.subscriptions);
}

class UpcomingPaymentsScreen extends StatefulWidget {
  const UpcomingPaymentsScreen({super.key});

  @override
  State<UpcomingPaymentsScreen> createState() => _UpcomingPaymentsScreenState();
}

class _UpcomingPaymentsScreenState extends State<UpcomingPaymentsScreen> {
  List<TimelineSection> _sections = [];
  int _renewalsThisWeek = 0;
  double _amountDueThisWeek = 0;

  @override
  void initState() {
    super.initState();
    SubscriptionService.instance.addListener(_onSubscriptionsChanged);
    _buildTimelineData();
  }

  @override
  void dispose() {
    SubscriptionService.instance.removeListener(_onSubscriptionsChanged);
    super.dispose();
  }

  void _onSubscriptionsChanged() {
    if (mounted) {
      _buildTimelineData();
    }
  }

  void _buildTimelineData() {
    final allSubs = SubscriptionService.instance.subscriptions;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int renewalsWeek = 0;
    double amountWeek = 0;

    final Map<int, List<SubscriptionModel>> buckets = {
      0: [], // Overdue
      1: [], // Today
      2: [], // Tomorrow
      3: [], // This Week (2-7 days)
      4: [], // Next Week (8-14 days)
    };

    for (final sub in allSubs) {
      if (sub.status == SubscriptionStatus.expired) continue;
      
      final target = DateTime(sub.nextRenewalDate.year, sub.nextRenewalDate.month, sub.nextRenewalDate.day);
      final diff = target.difference(today).inDays;
      
      if (diff >= 0 && diff <= 7) {
        renewalsWeek++;
        amountWeek += sub.currentPrice;
      }
      
      if (diff < 0) {
        buckets[0]!.add(sub);
      } else if (diff == 0) {
        buckets[1]!.add(sub);
      } else if (diff == 1) {
        buckets[2]!.add(sub);
      } else if (diff <= 7) {
        buckets[3]!.add(sub);
      } else if (diff <= 14) {
        buckets[4]!.add(sub);
      }
      // Renewals beyond 14 days are ignored to keep the screen concise and action-oriented.
    }
    
    // Sort buckets
    for (final list in buckets.values) {
      list.sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
    }

    final List<TimelineSection> sections = [];
    if (buckets[0]!.isNotEmpty) sections.add(TimelineSection('Overdue', buckets[0]!));
    if (buckets[1]!.isNotEmpty) sections.add(TimelineSection('Today', buckets[1]!));
    if (buckets[2]!.isNotEmpty) sections.add(TimelineSection('Tomorrow', buckets[2]!));
    if (buckets[3]!.isNotEmpty) {
      // Find what day it is for the first item
      sections.add(TimelineSection('This Week', buckets[3]!));
    }
    if (buckets[4]!.isNotEmpty) sections.add(TimelineSection('Next Week', buckets[4]!));

    setState(() {
      _sections = sections;
      _renewalsThisWeek = renewalsWeek;
      _amountDueThisWeek = amountWeek;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildHero(theme),
            Expanded(
              child: _sections.isEmpty
                  ? const UpcomingPaymentsEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _sections.length,
                      itemBuilder: (context, index) {
                        return _buildTimelineSection(theme, _sections[index], index == _sections.length - 1);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 4),
          Text(
            'Timeline',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Renewals',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_renewalsThisWeek renewals',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyFormatter.format(_amountDueThisWeek)} due this week',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month_rounded, color: theme.colorScheme.onPrimary, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(ThemeData theme, TimelineSection section, bool isLast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              section.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 5), // to align border with circle center (circle is 12 width)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                decoration: BoxDecoration(
                  border: isLast ? null : Border(
                    left: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(left: 22, top: 12, bottom: 24),
                child: Column(
                  children: section.subscriptions.map((sub) {
                    // Generate AI tip if applicable
                    String? aiTip;
                    if (sub.monthlyPrice > 500 && sub.billingCycle == BillingCycle.monthly) {
                      aiTip = 'High cost. Switch to annual?';
                    } else if (sub.name.toLowerCase().contains('trial')) {
                      aiTip = 'Trial ending soon!';
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: UpcomingPaymentCard(
                        subscription: sub,
                        aiTip: aiTip,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
