import 'package:flutter/material.dart';
import 'package:sanchora/features/subscriptions/services/subscription_service.dart';
import '../widgets/analytics_empty_state.dart';
import '../widgets/analytics_spending_behavior.dart';
import '../widgets/analytics_category_intelligence.dart';
import '../widgets/analytics_cost_concentration.dart';
import '../widgets/analytics_momentum_chart.dart';
import '../widgets/analytics_efficiency_score.dart';
import '../widgets/analytics_smart_recommendations.dart';
import '../widgets/analytics_monthly_insight.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    SubscriptionService.instance.addListener(_onSubscriptionsChanged);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    SubscriptionService.instance.removeListener(_onSubscriptionsChanged);
    _animController.dispose();
    super.dispose();
  }

  void _onSubscriptionsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildAnimatedModule(Widget child, int index) {
    // Staggered entrance animation
    final start = (index * 0.05).clamp(0.0, 1.0);
    final end = (start + 0.3).clamp(0.0, 1.0);
    
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptions = SubscriptionService.instance.subscriptions;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: subscriptions.isEmpty
            ? const AnalyticsEmptyState()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(theme),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildAnimatedModule(AnalyticsMonthlyInsight(subscriptions: subscriptions), 0),
                      _buildAnimatedModule(AnalyticsEfficiencyScore(subscriptions: subscriptions), 1),
                      _buildAnimatedModule(AnalyticsSmartRecommendations(subscriptions: subscriptions), 2),
                      _buildAnimatedModule(AnalyticsSpendingBehavior(subscriptions: subscriptions), 3),
                      _buildAnimatedModule(AnalyticsMomentumChart(subscriptions: subscriptions), 4),
                      _buildAnimatedModule(AnalyticsCategoryIntelligence(subscriptions: subscriptions), 5),
                      _buildAnimatedModule(AnalyticsCostConcentration(subscriptions: subscriptions), 6),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Executive insights & spending habits.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
