import 'package:flutter/material.dart';


import 'package:sanchora/core/widgets/app_header.dart';
import 'package:sanchora/core/widgets/sanchora_text_field.dart';

import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../widgets/subscription_card.dart';
import '../widgets/subscription_empty_state.dart';
import '../widgets/subscription_filter_chips.dart';
import '../widgets/subscription_summary.dart';
import '../widgets/subscription_sort_bottom_sheet.dart';

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

  final List<String> _filters = ['All', 'Active', 'Upcoming', 'Expired'];

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
      case SortOption.priceLowHigh:
        result.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case SortOption.priceHighLow:
        result.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case SortOption.renewalDate:
        result.sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Subscriptions',
              actions: [
                IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  onPressed: _showSortOptions,
                ),
              ],
            ),
            
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: SanchoraTextField(
                        controller: _searchController,
                        hintText: 'Search subscriptions...',
                        prefixIcon: Icons.search,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: SubscriptionFilterChips(
                        filters: _filters,
                        selectedFilter: _selectedFilter,
                        onFilterSelected: _onFilterSelected,
                      ),
                    ),
                  ),

                  if (_searchController.text.isEmpty && _selectedFilter == 'All') ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: SubscriptionSummary(
                          totalSubscriptions: SubscriptionService.instance.subscriptions.length,
                          monthlySpending: monthlySpending,
                          yearlySpending: yearlySpending,
                        ),
                      ),
                    ),
                  ],

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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final subscription = _filteredSubscriptions[index];
                            return SubscriptionCard(
                              subscription: subscription,
                              onEdit: () {
                                // Placeholder for edit
                              },
                              onDelete: () {
                                SubscriptionService.instance.removeSubscription(subscription);
                              },
                            );
                          },
                          childCount: _filteredSubscriptions.length,
                        ),
                      ),
                    ),
                    
                  // Add bottom padding to account for Bottom Nav Bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
