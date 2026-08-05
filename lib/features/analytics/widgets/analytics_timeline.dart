import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/models/subscription_model.dart';
import 'package:sanchora/core/theme/app_colors.dart';
import 'package:sanchora/features/subscriptions/widgets/subscription_icon.dart';
import 'package:intl/intl.dart';

class AnalyticsTimeline extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const AnalyticsTimeline({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (subscriptions.isEmpty) return const SizedBox.shrink();

    // Sort ascending by startDate
    final sortedSubs = List<SubscriptionModel>.from(subscriptions)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.timeline_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Subscription Journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: sortedSubs.length,
            itemBuilder: (context, index) {
              final sub = sortedSubs[index];
              final isFirst = index == 0;
              final isLast = index == sortedSubs.length - 1;
              
              return SizedBox(
                width: 100,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      DateFormat('yyyy').format(sub.startDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Timeline nodes and lines
                    SizedBox(
                      height: 24,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: isFirst ? Colors.transparent : theme.colorScheme.outlineVariant,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: isLast ? Colors.transparent : theme.colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.surface, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SubscriptionIcon(
                      iconIdentifier: sub.iconUrl.isNotEmpty ? sub.iconUrl : sub.name,
                      fallbackName: sub.name,
                      category: sub.category,
                      size: 40,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sub.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
