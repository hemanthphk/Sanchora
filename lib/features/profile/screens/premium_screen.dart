import 'package:flutter/material.dart';
import 'package:sanchora/core/widgets/sanchora_page_header.dart';
const premiumGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF7C3AED),
    Color(0xFFF5B301),
  ],
);

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const SanchoraPageHeader(title: 'Premium'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroSection(theme, isDark),
                    const SizedBox(height: 32),
                    _buildComparisonCard(theme, isDark),
                    const SizedBox(height: 32),
                    _buildFeaturesList(theme, isDark),
                    const SizedBox(height: 32),
                    _buildPricingSection(theme, isDark),
                  ],
                ),
              ),
            ),
            _buildBottomCta(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: premiumGradient,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Sanchora Premium',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Unlock the ultimate subscription management experience with advanced AI and powerful analytics.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(ThemeData theme, bool isDark) {
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Feature',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Free',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Premium',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          _buildComparisonRow(theme, 'Basic Tracking', true, true, borderColor),
          _buildComparisonRow(theme, 'Alerts', true, true, borderColor),
          _buildComparisonRow(theme, 'AI Insights', false, true, borderColor),
          _buildComparisonRow(theme, 'Smart Savings', false, true, borderColor),
          _buildComparisonRow(theme, 'Family Sharing', false, true, Colors.transparent),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(ThemeData theme, String feature, bool free, bool premium, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Icon(
              free ? Icons.check_rounded : Icons.close_rounded,
              color: free ? const Color(0xFF10B981) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              size: 20,
            ),
          ),
          SizedBox(
            width: 80,
            child: Icon(
              premium ? Icons.check_rounded : Icons.close_rounded,
              color: premium ? const Color(0xFF7C3AED) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          theme,
          icon: Icons.auto_awesome_rounded,
          title: 'AI Spending Insights',
          desc: 'Get personalized insights and predictions powered by AI.',
          iconColor: const Color(0xFF7C3AED),
          bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
        ),
        _buildFeatureItem(
          theme,
          icon: Icons.savings_rounded,
          title: 'Smart Savings Recommendations',
          desc: 'Discover ways to save money automatically.',
          iconColor: const Color(0xFFF5B301),
          bgColor: const Color(0xFFF5B301).withValues(alpha: 0.1),
        ),
        _buildFeatureItem(
          theme,
          icon: Icons.analytics_rounded,
          title: 'Advanced Analytics',
          desc: 'Deep dive into your subscription habits and trends.',
          iconColor: const Color(0xFF4F46E5),
          bgColor: const Color(0xFF4F46E5).withValues(alpha: 0.1),
        ),
        _buildFeatureItem(
          theme,
          icon: Icons.edit_calendar_rounded,
          title: 'Smart Renewal Calendar',
          desc: 'Visualize all your upcoming renewals seamlessly.',
          iconColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
        ),
        _buildFeatureItem(
          theme,
          icon: Icons.notifications_active_rounded,
          title: 'Intelligent Alerts',
          desc: 'Customizable and predictive notification system.',
          iconColor: const Color(0xFFF97316),
          bgColor: const Color(0xFFF97316).withValues(alpha: 0.1),
        ),
        _buildFeatureItem(
          theme,
          icon: Icons.family_restroom_rounded,
          title: 'Family Sharing',
          desc: 'Share your premium benefits with up to 5 family members.',
          iconColor: const Color(0xFF10B981),
          bgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
        ),
        _buildFeatureItem(
          theme,
          icon: Icons.rocket_launch_rounded,
          title: 'Early Access Features',
          desc: 'Get exclusive access to new tools before anyone else.',
          iconColor: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        ),
        _buildFeatureItem(
          theme,
          icon: Icons.support_agent_rounded,
          title: 'Priority Support',
          desc: 'Skip the line and get faster responses from our team.',
          iconColor: const Color(0xFF6D28D9),
          bgColor: const Color(0xFF6D28D9).withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(ThemeData theme, {required IconData icon, required String title, required String desc, required Color iconColor, required Color bgColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5B301).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF5B301).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5B301).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF5B301), size: 14),
                const SizedBox(width: 4),
                Text(
                  'COMING SOON',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF333333),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Premium plans will be available soon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: premiumGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("We'll notify you when Premium launches."),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Notify Me When Premium Launches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
