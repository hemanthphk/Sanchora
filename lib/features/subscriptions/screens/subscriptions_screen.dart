import 'package:flutter/material.dart';
import 'package:sanchora/core/widgets/sanchora_text_field.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../widgets/subscription_card.dart';
import '../widgets/subscription_empty_state.dart';
import '../widgets/subscription_filter_chips.dart';
import '../widgets/subscription_summary.dart';
import '../widgets/subscription_sort_bottom_sheet.dart';

/// Command Center management dashboard for Subscriptions.
/// Designed with Apple, Stripe Dashboard, and Linear aesthetics.
/// Completely distinct from the timeline-focused Upcoming Payments page:
/// prioritizes sticky search, filter chips, dominant Total Subscriptions metrics,
/// and direct always-visible action pills [View], [Edit], [Delete].
/// Future-ready for bulk management (multi-select, pause, delete, export) without redesign.
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  SortOption _currentSort = SortOption.nameAsc;

  List<SubscriptionModel> _filteredSubscriptions = [];

  final List<String> _filters = ['All', 'Active', 'Upcoming', 'Expired', 'Paused'];

  @override
  void initState() {
    super.initState();
    SubscriptionService.instance.addListener(_onSubscriptionsChanged);
    _filteredSubscriptions = List.from(SubscriptionService.instance.subscriptions);
    _applyFiltersAndSort();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    SubscriptionService.instance.removeListener(_onSubscriptionsChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSubscriptionsChanged() {
    if (mounted) {
      _applyFiltersAndSort();
    }
  }

  void _onSearchChanged() {
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort({bool notify = true}) {
    List<SubscriptionModel> result = List.from(SubscriptionService.instance.subscriptions);

    // Filter by Search Query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((sub) {
        return sub.name.toLowerCase().contains(query) ||
               sub.category.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by Status
    if (_selectedFilter != 'All') {
      final status = _selectedFilter.toLowerCase();
      result = result.where((sub) {
        return sub.status.name.toLowerCase() == status;
      }).toList();
    }

    // Sort
    switch (_currentSort) {
      case SortOption.nameAsc:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.priceHighLow:
        result.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case SortOption.priceLowHigh:
        result.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case SortOption.renewalDate:
        result.sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
        break;
      case SortOption.recentlyAdded:
        final allIds = SubscriptionService.instance.subscriptions.map((s) => s.id).toList();
        result.sort((a, b) => allIds.indexOf(b.id).compareTo(allIds.indexOf(a.id)));
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
    final newSort = await SubscriptionSortBottomSheet.show(context, _currentSort);
    if (newSort != null && newSort != _currentSort) {
      setState(() {
        _currentSort = newSort;
      });
      _applyFiltersAndSort();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate summary statistics
    double monthlySpending = 0;
    double yearlySpending = 0;
    for (var sub in SubscriptionService.instance.subscriptions) {
      monthlySpending += sub.monthlyPrice;
      yearlySpending += sub.yearlyPrice;
    }

    final isSearchingOrFiltering = _searchController.text.isNotEmpty || _selectedFilter != 'All';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(theme),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchBarDelegate(
                searchController: _searchController,
                onClearSearch: () => _searchController.clear(),
                theme: theme,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 12),
                child: SubscriptionSummary(
                  totalSubscriptions: SubscriptionService.instance.subscriptions.length,
                  monthlySpending: monthlySpending,
                  yearlySpending: yearlySpending,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: SubscriptionFilterChips(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  onFilterSelected: _onFilterSelected,
                ),
              ),
            ),

            if (isSearchingOrFiltering && _filteredSubscriptions.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 8),
                  child: Text(
                    '${_filteredSubscriptions.length} ${_filteredSubscriptions.length == 1 ? 'result' : 'results'} found',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

            if (SubscriptionService.instance.subscriptions.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SubscriptionEmptyState(isSearch: false),
              )
            else if (_filteredSubscriptions.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SubscriptionEmptyState(isSearch: true),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subscription = _filteredSubscriptions[index];
                      return SubscriptionCard(
                        subscription: subscription,
                        onDelete: () {
                          SubscriptionService.instance.removeSubscription(subscription);
                        },
                      );
                    },
                    childCount: _filteredSubscriptions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscriptions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage all your subscriptions.',
                  style: TextStyle(
                    fontSize: 14,
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

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final VoidCallback onClearSearch;
  final ThemeData theme;

  _StickySearchBarDelegate({
    required this.searchController,
    required this.onClearSearch,
    required this.theme,
  });

  @override
  double get minExtent => 68.0;

  @override
  double get maxExtent => 68.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SanchoraTextField(
          controller: searchController,
          hintText: 'Search subscriptions...',
          prefixIcon: Icons.search,
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: onClearSearch,
                )
              : null,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) {
    return oldDelegate.searchController.text != searchController.text ||
        oldDelegate.theme != theme;
  }
}
