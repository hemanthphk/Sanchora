import 'package:flutter/material.dart';

class SubscriptionIntentChips extends StatelessWidget {
  final List<String> intents;
  final String selectedIntent;
  final Function(String) onIntentSelected;

  const SubscriptionIntentChips({
    super.key,
    required this.intents,
    required this.selectedIntent,
    required this.onIntentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: intents.map((intent) {
          final isSelected = selectedIntent == intent;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChip(context, intent, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String intent, bool isSelected) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onIntentSelected(intent),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            intent,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
