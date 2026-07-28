import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../widgets/subscription_card.dart';
import '../widgets/subscription_empty_state.dart';
import '../widgets/subscription_intent_chips.dart';
import '../widgets/ai_hero_card.dart';
import '../widgets/subscription_bottom_sheet_filter.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedIntent = '⭐ All';

  List<SubscriptionModel> _filteredSubscriptions = [];

  final List<String> _intents = [
    '⭐ All',
    '⏰ Due Soon',
    '💸 High Spend',
    '🎁 Free Trials',
    '🤖 AI Picks',
    '📅 This Month'
  ];

  @override
  void initState() {
    super.initState();
    SubscriptionService.instance.addListener(_onSubscriptionsChanged);
    _filteredSubscriptions = List.from(SubscriptionService.instance.subscriptions);
    _applyFiltersAndSort();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    SubscriptionService.instance.removeListener(_onSubscriptionsChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter by Search Query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((sub) {
        return sub.name.toLowerCase().contains(query) ||
               sub.category.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by Intent
    switch (_selectedIntent) {
      case '⏰ Due Soon':
        result = result.where((sub) {
          if (sub.status == SubscriptionStatus.expired) return false;
          final target = DateTime(sub.nextRenewalDate.year, sub.nextRenewalDate.month, sub.nextRenewalDate.day);
          final diff = target.difference(today).inDays;
          return diff >= 0 && diff <= 7;
        }).toList();
        result.sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
        break;
      case '💸 High Spend':
        result = result.where((sub) => sub.status != SubscriptionStatus.expired).toList();
        result.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case '🎁 Free Trials':
        result = result.where((sub) => sub.status != SubscriptionStatus.expired && (sub.name.toLowerCase().contains('trial') || sub.currentPrice == 0)).toList();
        break;
      case '🤖 AI Picks':
        result = result.where((sub) => sub.status != SubscriptionStatus.expired).toList();
        // Just an AI example sort (random or specific logic)
        result.sort((a, b) => a.name.length.compareTo(b.name.length));
        break;
      case '📅 This Month':
        result = result.where((sub) {
          if (sub.status == SubscriptionStatus.expired) return false;
          return sub.nextRenewalDate.month == today.month && sub.nextRenewalDate.year == today.year;
        }).toList();
        result.sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
        break;
      default: // ⭐ All
        result.sort((a, b) => a.name.compareTo(b.name));
    }

    // AI Recommendations generation logic removed from UI layer as per design

    if (notify) {
      setState(() {
        _filteredSubscriptions = result;
      });
    } else {
      _filteredSubscriptions = result;
    }
  }

  void _onIntentSelected(String intent) {
    setState(() {
      _selectedIntent = intent;
    });
    _applyFiltersAndSort();
  }

  Future<void> _showFilterOptions() async {
    await SubscriptionBottomSheetFilter.show(context);
    // You could update state based on bottom sheet result here.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSearchingOrFiltering = _searchController.text.isNotEmpty || _selectedIntent != '⭐ All';
    final isSearchActive = _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;

    return GestureDetector(
      onTap: () {
        // Unfocus the search field when tapping outside
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(theme),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchBarDelegate(
                searchController: _searchController,
                focusNode: _searchFocusNode,
                onClearSearch: () => _searchController.clear(),
                theme: theme,
              ),
            ),

            SliverToBoxAdapter(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCirc,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, -0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: isSearchActive
                      ? const SizedBox(key: ValueKey('empty_hero'), width: double.infinity, height: 0)
                      : Padding(
                          key: const ValueKey('hero_card'),
                          padding: const EdgeInsets.only(top: 12, bottom: 20),
                          child: AiHeroCard(
                            subscriptions: SubscriptionService.instance.subscriptions,
                          ),
                        ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SubscriptionIntentChips(
                  intents: _intents,
                  selectedIntent: _selectedIntent,
                  onIntentSelected: _onIntentSelected,
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
                      fontWeight: FontWeight.w600,
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
                      if (isSearchActive) {
                        if (index >= _filteredSubscriptions.length) return const SizedBox.shrink();
                        final subscription = _filteredSubscriptions[index];
                        return SubscriptionCard(
                          subscription: subscription,
                          onDelete: () {
                            SubscriptionService.instance.removeSubscription(subscription);
                          },
                        );
                      }

                      // Render subscriptions first
                      if (index < _filteredSubscriptions.length) {
                        final subscription = _filteredSubscriptions[index];
                        
                        // Assign a tip if it's the highest spend
                        String? aiTip;
                        if (_selectedIntent == '💸 High Spend' && index == 0) {
                          aiTip = 'Highest monthly cost. Consider annual billing.';
                        }

                        return SubscriptionCard(
                          subscription: subscription,
                          aiTip: aiTip,
                          onDelete: () {
                            SubscriptionService.instance.removeSubscription(subscription);
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    childCount: _filteredSubscriptions.length,
                  ),
                ),
              ),
          ],
        ),
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
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your recurring payments.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, size: 22),
              onPressed: _showFilterOptions,
              color: theme.colorScheme.onSurface,
              tooltip: 'Filters',
            ),
          ),
        ],
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final VoidCallback onClearSearch;
  final ThemeData theme;

  _StickySearchBarDelegate({
    required this.searchController,
    required this.focusNode,
    required this.onClearSearch,
    required this.theme,
  });

  @override
  double get minExtent => 70.0;

  @override
  double get maxExtent => 70.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      focusNode: focusNode,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search subscriptions...',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: onClearSearch,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) {
    return oldDelegate.searchController.text != searchController.text ||
        oldDelegate.focusNode.hasFocus != focusNode.hasFocus ||
        oldDelegate.theme != theme;
  }
}

