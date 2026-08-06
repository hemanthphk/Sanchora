import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanchora/features/auth/screens/login_screen.dart';
import 'package:sanchora/core/services/currency_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingPageData> get _pages => [
    _OnboardingPageData(
      title: 'Track. Manage.\nNever Miss.',
      subtitle: 'All your subscriptions in one place.\nStay on top, save more.',
      accentColor: const Color(0xFF0A84FF),
      showPremiumPhone: true,
    ),
    _OnboardingPageData(
      title: 'Get Reminded.\nStay Ahead.',
      subtitle:
          'Smart reminders before every due date\nso you never miss a payment.',
      accentColor: const Color(0xFF0A84FF),
      showPremiumPhone: false,
    ),
    _OnboardingPageData(
      title: 'Stay in control',
      subtitle: 'Manage renewals and plans without the hassle.',
      accentColor: const Color(0xFF0A84FF),
      showPremiumPhone: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingCompleted', true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  if (index == 1) {
                    return _buildSecondPage(page);
                  }
                  if (index == 2) {
                    return _buildThirdPage(page);
                  }
                  if (page.showPremiumPhone) {
                    return _buildFirstPage(page);
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 14, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final active = index == _currentPage;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        width: active ? 28 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF0A84FF)
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                  if (_currentPage == 1)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _goToNextPage,
                            icon: Icon(Icons.arrow_forward_rounded, size: 18),
                            label: Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A84FF),
                              foregroundColor: Theme.of(context).cardColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _goToNextPage,
                            icon: Icon(Icons.arrow_forward_rounded, size: 18),
                            label: Text(
                              isLastPage ? 'Get Started' : 'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A84FF),
                              foregroundColor: Theme.of(context).cardColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already a member? ',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: _goToLogin,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                              ),
                              child: Text(
                                'Log in',
                                style: TextStyle(
                                  color: const Color(0xFF0A84FF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondPage(_OnboardingPageData page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 24,
                  left: -12,
                  child: _buildRing(120, 0x140B1F4D),
                ),
                Positioned(
                  bottom: 34,
                  right: -18,
                  child: _buildRing(150, 0x0F0A84FF),
                ),
                Positioned(
                  top: 36,
                  left: 30,
                  child: _buildFloatingChip(
                    icon: Icons.notifications_active_rounded,
                    size: 24,
                    color: const Color(0xFF0A84FF),
                  ),
                ),
                Positioned(
                  bottom: 86,
                  left: 18,
                  child: _buildFloatingChip(
                    icon: Icons.calendar_today_rounded,
                    size: 22,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Positioned(
                  top: 36,
                  right: 30,
                  child: _buildFloatingChip(
                    icon: Icons.credit_card_rounded,
                    size: 24,
                    color: const Color(0xFF0A84FF),
                  ),
                ),
                Positioned(
                  bottom: 86,
                  right: 18,
                  child: _buildFloatingChip(
                    icon: Icons.check_circle_rounded,
                    size: 24,
                    color: const Color(0xFF0A84FF),
                  ),
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 380),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withValues(alpha: 0.05) 
                          : Colors.black.withValues(alpha: 0.03),
                      width: 1,
                    ),
                    boxShadow: [
                      if (Theme.of(context).brightness == Brightness.light)
                        BoxShadow(
                          color: Color(0x1A0B1F4D),
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              'https://logo.clearbit.com/spotify.com',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.music_note_rounded,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Spotify',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${CurrencyService.instance.format(119)} / month',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Theme.of(context).colorScheme.surfaceContainerHighest 
                              : const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due: 25 May',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Status: Due Tomorrow',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0A84FF),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: [
                TextSpan(text: 'Get Reminded.\n'),
                TextSpan(
                  text: 'Stay Ahead.',
                  style: TextStyle(color: const Color(0xFF0A84FF)),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Smart reminders before every due date\nso you never miss a payment.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPage(_OnboardingPageData page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;

          return Column(
            children: [
              SizedBox(height: availableHeight < 700 ? 2 : 4),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 24,
                      left: -10,
                      child: _buildGradientRing(120, const Color(0xFF0A84FF)),
                    ),
                    Positioned(
                      bottom: 30,
                      right: -14,
                      child: _buildGradientRing(150, const Color(0xFF2563EB)),
                    ),
                    Positioned(
                      top: 40,
                      left: 24,
                      child: _buildFloatingChip(
                        icon: Icons.trending_up_rounded,
                        size: 22,
                        color: const Color(0xFF0A84FF),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 24,
                      child: _buildFloatingChip(
                        icon: Icons.pie_chart_rounded,
                        size: 22,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    Positioned(
                      bottom: 82,
                      left: 20,
                      child: _buildFloatingChip(
                        icon: Icons.wallet_rounded,
                        size: 22,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Positioned(
                      bottom: 82,
                      right: 20,
                      child: _buildFloatingChip(
                        icon: Icons.savings_rounded,
                        size: 22,
                        color: const Color(0xFF0A84FF),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 380),
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white.withValues(alpha: 0.05) 
                              : Colors.black.withValues(alpha: 0.03),
                          width: 1,
                        ),
                        boxShadow: [
                          if (Theme.of(context).brightness == Brightness.light)
                            BoxShadow(
                              color: Color(0x1A0B1F4D),
                              blurRadius: 32,
                              offset: Offset(0, 16),
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAnalyticsRow(
                            'https://logo.clearbit.com/netflix.com',
                            'Netflix',
                            CurrencyService.instance.format(649),
                          ),
                          SizedBox(height: 12),
                          _buildAnalyticsRow(
                            'https://logo.clearbit.com/spotify.com',
                            'Spotify',
                            CurrencyService.instance.format(119),
                          ),
                          SizedBox(height: 12),
                          _buildAnalyticsRow(
                            'https://logo.clearbit.com/amazon.com',
                            'Amazon Prime',
                            CurrencyService.instance.format(299),
                          ),
                          SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFFF3F9FF)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Spending trend',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 16),
                                LayoutBuilder(
                                  builder: (context, chartConstraints) {
                                    final barHeight = (chartConstraints.maxWidth * 0.18).clamp(28.0, 70.0);
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildChartBar(barHeight, const Color(0xFF0A84FF)),
                                        _buildChartBar(barHeight + 20, const Color(0xFF2563EB)),
                                        _buildChartBar(barHeight + 36, const Color(0xFF0A84FF)),
                                        _buildChartBar(barHeight + 14, const Color(0xFF0A84FF)),
                                        _buildChartBar(barHeight + 46, const Color(0xFF2563EB)),
                                        _buildChartBar(barHeight + 28, const Color(0xFF0A84FF)),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface, // Primary text
                  ),
                  children: [
                    TextSpan(text: 'Understand.\n'),
                    TextSpan(
                      text: 'Save More.',
                      style: TextStyle(color: const Color(0xFF0A84FF)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Track your monthly and yearly subscription spending with beautiful insights and make smarter financial decisions.',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant, // Secondary text
                  height: 1.45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFirstPage(_OnboardingPageData page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 18,
                  left: -8,
                  child: _buildRing(110, 0x14FFFFFF),
                ),
                Positioned(
                  bottom: 40,
                  right: -16,
                  child: _buildRing(140, 0x0F0A84FF),
                ),
                Positioned(
                  top: 42,
                  child: _buildFloatingChip(
                    icon: Icons.notifications_active_rounded,
                    size: 44,
                    color: const Color(0xFF0A84FF),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 140,
                  child: _buildFloatingChip(
                    icon: Icons.currency_rupee_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Positioned(
                  left: -4,
                  bottom: 88,
                  child: _buildFloatingChip(
                    icon: Icons.calendar_today_rounded,
                    size: 38,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 150,
                  child: _buildFloatingChip(
                    icon: Icons.insights_rounded,
                    size: 40,
                    color: const Color(0xFF0A84FF),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 92,
                  child: _buildFloatingChip(
                    icon: Icons.shield_outlined,
                    size: 40,
                    color: const Color(0xFF0A84FF),
                  ),
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 380),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withValues(alpha: 0.05) 
                          : Colors.black.withValues(alpha: 0.03),
                      width: 1,
                    ),
                    boxShadow: [
                      if (Theme.of(context).brightness == Brightness.light)
                        BoxShadow(
                          color: Color(0x1A0B1F4D),
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSubscriptionCard(
                        logoUrl: 'https://logo.clearbit.com/netflix.com',
                        title: 'Netflix',
                        amount: CurrencyService.instance.format(649),
                        status: 'Active',
                        statusColor: const Color(0xFF166534),
                      ),
                      SizedBox(height: 12),
                      _buildSubscriptionCard(
                        logoUrl: 'https://logo.clearbit.com/spotify.com',
                        title: 'Spotify',
                        amount: CurrencyService.instance.format(119),
                        status: 'Due Soon',
                        statusColor: const Color(0xFFEA580C),
                      ),
                      SizedBox(height: 12),
                      _buildSubscriptionCard(
                        logoUrl: 'https://logo.clearbit.com/amazon.com',
                        title: 'Amazon Prime',
                        amount: CurrencyService.instance.format(299),
                        status: 'Auto Renew',
                        statusColor: const Color(0xFF0A84FF),
                      ),
                      SizedBox(height: 12),
                      _buildSubscriptionCard(
                        logoUrl: 'https://logo.clearbit.com/youtube.com',
                        title: 'YouTube',
                        amount: CurrencyService.instance.format(149),
                        status: 'Active',
                        statusColor: const Color(0xFF166534),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: [
                TextSpan(text: 'Track. Manage.\n'),
                TextSpan(
                  text: 'Never Miss.',
                  style: TextStyle(color: const Color(0xFF0A84FF)),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'All your subscriptions in one place.\nStay on top, save more.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String logoUrl,
    required String title,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.subscriptions_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String logoUrl, String title, String amount) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.subscriptions_rounded,
              size: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : const Color(0xFF0A84FF),
          ),
        ),
      ],
    );
  }

  Widget _buildChartBar(double height, Color color) {
    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.7),
            color,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingChip({
    required IconData icon,
    required double size,
    required Color color,
  }) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x150B1F4D),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, size: size, color: color),
    );
  }

  Widget _buildRing(double size, int colorValue) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(colorValue).withValues(alpha: 0.65),
          width: 1.2,
        ),
      ),
    );
  }

  Widget _buildGradientRing(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.03),
          ],
          stops: [0.2, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.showPremiumPhone,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final bool showPremiumPhone;
}
