import 'package:flutter/material.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/features/subscriptions/models/subscription_filter_state.dart';

class SubscriptionBottomSheetFilter extends StatefulWidget {
  final SubscriptionFilterState initialState;
  final List<String> availableCategories;

  const SubscriptionBottomSheetFilter({
    super.key,
    required this.initialState,
    required this.availableCategories,
  });

  static Future<SubscriptionFilterState?> show(
    BuildContext context, {
    required SubscriptionFilterState initialState,
    required List<String> availableCategories,
  }) async {
    return showModalBottomSheet<SubscriptionFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubscriptionBottomSheetFilter(
        initialState: initialState,
        availableCategories: availableCategories,
      ),
    );
  }

  @override
  State<SubscriptionBottomSheetFilter> createState() => _SubscriptionBottomSheetFilterState();
}

class _SubscriptionBottomSheetFilterState extends State<SubscriptionBottomSheetFilter> {
  late SubscriptionFilterState _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (_currentState.category == category) {
        _currentState = _currentState.copyWith(clearCategory: true);
      } else {
        _currentState = _currentState.copyWith(category: category);
      }
    });
  }

  void _onBillingCycleSelected(BillingCycle cycle) {
    setState(() {
      if (_currentState.billingCycle == cycle) {
        _currentState = _currentState.copyWith(clearBillingCycle: true);
      } else {
        _currentState = _currentState.copyWith(billingCycle: cycle);
      }
    });
  }

  void _onReset() {
    setState(() {
      _currentState = const SubscriptionFilterState();
    });
  }

  void _onApply() {
    Navigator.pop(context, _currentState);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppTextStyles.sectionTitle.copyWith(color: theme.colorScheme.onSurface),
              ),
              if (_currentState.isActive)
                TextButton(
                  onPressed: _onReset,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCategorySection(theme),
          const SizedBox(height: 20),
          _buildBillingCycleSection(theme),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    if (widget.availableCategories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableCategories.map((category) {
            final isSelected = _currentState.category == category;
            return GestureDetector(
              onTap: () => _onCategorySelected(category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBillingCycleSection(ThemeData theme) {
    final Map<BillingCycle, String> cycles = {
      BillingCycle.monthly: 'Monthly',
      BillingCycle.yearly: 'Yearly',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Cycle',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cycles.entries.map((entry) {
            final cycle = entry.key;
            final label = entry.value;
            final isSelected = _currentState.billingCycle == cycle;
            return GestureDetector(
              onTap: () => _onBillingCycleSelected(cycle),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
