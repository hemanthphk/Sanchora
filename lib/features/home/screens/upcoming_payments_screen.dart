import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';
import '../widgets/upcoming_payment_card.dart';
import '../widgets/upcoming_payments_empty_state.dart';
import '../widgets/upcoming_payments_filter_chips.dart';
import '../widgets/upcoming_payments_sort_bottom_sheet.dart';
import '../widgets/upcoming_payments_summary_card.dart';

class TimelineSection {
  final String title;
  final List<SubscriptionModel> subscriptions;
  const TimelineSection(this.title, this.subscriptions);
}

/// Premium timeline experience for Upcoming Payments.
/// Designed with Apple Wallet, Stripe Dashboard, Linear, and Notion Timeline aesthetics.
/// Future-ready for calendar sync, notifications, AI reminders, and snooze controls without redesign.
class UpcomingPaymentsScreen extends StatefulWidget {
  const UpcomingPaymentsScreen({super.key});

  @override
  State<UpcomingPaymentsScreen> createState() => _UpcomingPaymentsScreenState();
}

class _UpcomingPaymentsScreenState extends State<UpcomingPaymentsScreen> {
  String _selectedFilter = 'All';
  UpcomingSortOption _currentSort = UpcomingSortOption.nearestFirst;
  List<SubscriptionModel> _filteredSubscriptions = [];

  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    SubscriptionService.instance.addListener(_onSubscriptionsChanged);
    _applyFiltersAndSort(notify: false);
  }

  @override
  void dispose() {
    SubscriptionService.instance.removeListener(_onSubscriptionsChanged);
    super.dispose();
  }

  void _onSubscriptionsChanged() {
    if (mounted) {
      _applyFiltersAndSort();
    }
  }

  void _applyFiltersAndSort({bool notify = true}) {
    final allSubs = SubscriptionService.instance.subscriptions;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Include subscriptions that are not expired or have future/today renewal dates
    List<SubscriptionModel> result = allSubs.where((sub) {
      if (sub.status == SubscriptionStatus.expired) return false;
      final target = DateTime(
        sub.nextRenewalDate.year,
        sub.nextRenewalDate.month,
        sub.nextRenewalDate.day,
      );
      return target.difference(today).inDays >= 0;
    }).toList();

    // Apply Filter Chips
    if (_selectedFilter != 'All') {
      result = result.where((sub) {
        final target = DateTime(
          sub.nextRenewalDate.year,
          sub.nextRenewalDate.month,
          sub.nextRenewalDate.day,
        );
        final diff = target.difference(today).inDays;

        if (_selectedFilter == 'Today') {
          return diff == 0;
        } else if (_selectedFilter == 'This Week') {
          return diff >= 0 && diff <= 7;
        } else if (_selectedFilter == 'This Month') {
          return diff >= 0 && diff <= 30;
        }
        return true;
      }).toList();
    }

    // Apply Sorting
    switch (_currentSort) {
      case UpcomingSortOption.nearestFirst:
        result.sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
        break;
      case UpcomingSortOption.highestAmount:
        result.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case UpcomingSortOption.lowestAmount:
        result.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case UpcomingSortOption.alphabetical:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    if (notify) {
      setState(() {
        _filteredSubscriptions = result;
      });
    } else {
      _filteredSubscriptions = result;
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFiltersAndSort();
  }

  Future<void> _showSortOptions() async {
    final newSort = await UpcomingPaymentsSortBottomSheet.show(context, _currentSort);
    if (newSort != null && newSort != _currentSort) {
      setState(() {
        _currentSort = newSort;
      });
      _applyFiltersAndSort();
    }
  }

  List<TimelineSection> _buildTimelineSections(List<SubscriptionModel> subs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final Map<int, List<SubscriptionModel>> buckets = {
      0: [], // Overdue
      1: [], // Today
      2: [], // Tomorrow
      3: [], // This Week (2-7 days)
      4: [], // Next Week (8-14 days)
      5: [], // This Month (15-30 days)
      6: [], // Later (>30 days)
    };

    for (final sub in subs) {
      final target = DateTime(sub.nextRenewalDate.year, sub.nextRenewalDate.month, sub.nextRenewalDate.day);
      final diff = target.difference(today).inDays;
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
      } else if (diff <= 30) {
        buckets[5]!.add(sub);
      } else {
        buckets[6]!.add(sub);
      }
    }

    final List<TimelineSection> sections = [];

    if (buckets[0]!.isNotEmpty) {
      sections.add(TimelineSection('OVERDUE', buckets[0]!));
    }
    if (buckets[1]!.isNotEmpty) {
      final dateStr = DateFormat('dd MMM').format(buckets[1]!.first.nextRenewalDate);
      sections.add(TimelineSection('TODAY • $dateStr', buckets[1]!));
    }
    if (buckets[2]!.isNotEmpty) {
      final dateStr = DateFormat('dd MMM').format(buckets[2]!.first.nextRenewalDate);
      sections.add(TimelineSection('TOMORROW • $dateStr', buckets[2]!));
    }
    if (buckets[3]!.isNotEmpty) {
      sections.add(TimelineSection('THIS WEEK', buckets[3]!));
    }
    if (buckets[4]!.isNotEmpty) {
      sections.add(TimelineSection('NEXT WEEK', buckets[4]!));
    }
    if (buckets[5]!.isNotEmpty) {
      sections.add(TimelineSection('THIS MONTH', buckets[5]!));
    }
    if (buckets[6]!.isNotEmpty) {
      sections.add(TimelineSection('LATER', buckets[6]!));
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allSubs = SubscriptionService.instance.subscriptions;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int todayCount = 0;
    int thisWeekCount = 0;
    int thisMonthCount = 0;

    for (final sub in allSubs) {
      if (sub.status == SubscriptionStatus.expired) continue;
      final target = DateTime(sub.nextRenewalDate.year, sub.nextRenewalDate.month, sub.nextRenewalDate.day);
      final diff = target.difference(today).inDays;
      if (diff < 0) continue;
      if (diff == 0) todayCount++;
      if (diff <= 7) thisWeekCount++;
      if (diff <= 30) thisMonthCount++;
    }

    final sections = _buildTimelineSections(_filteredSubscriptions);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(height: 6),
            UpcomingPaymentsSummaryCard(
              todayCount: todayCount,
              thisWeekCount: thisWeekCount,
              thisMonthCount: thisMonthCount,
            ),
            const SizedBox(height: 14),
            UpcomingPaymentsFilterChips(
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterSelected: _onFilterSelected,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredSubscriptions.isEmpty
                  ? const UpcomingPaymentsEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      physics: const BouncingScrollPhysics(),
                      itemCount: sections.length,
                      itemBuilder: (context, sectionIndex) {
                        final section = sections[sectionIndex];
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, 12 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(theme, section.title),
                              ...section.subscriptions.map((sub) => UpcomingPaymentCard(subscription: sub)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Payments',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your upcoming renewals.',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded, size: 24),
            onPressed: _showSortOptions,
            color: theme.colorScheme.onSurface,
            tooltip: 'Sort By',
          ),
        ],
      ),
    );
  }
}
