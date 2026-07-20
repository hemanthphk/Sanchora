import 'package:flutter/material.dart';
import 'package:sanchora/features/auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    const _OnboardingPageData(
      title: 'Track. Manage.\nNever Miss.',
      subtitle: 'All your subscriptions in one place.\nStay on top, save more.',
      accentColor: Color(0xFF1677FF),
      showPremiumPhone: true,
    ),
    const _OnboardingPageData(
      title: 'Get Reminded.\nStay Ahead.',
      subtitle: 'Smart reminders before every due date\nso you never miss a payment.',
      accentColor: Color(0xFF3B82F6),
      showPremiumPhone: false,
    ),
    const _OnboardingPageData(
      title: 'Stay in control',
      subtitle: 'Manage renewals and plans without the hassle.',
      accentColor: Color(0xFF60A5FA),
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
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B1F4D),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
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
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        final active = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: active ? 28 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF1677FF)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    if (_currentPage == 1)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _goToNextPage,
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1677FF),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                color: Color(0xFF64748B),
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
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: Text(
                                isLastPage ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1677FF),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 15,
                                ),
                              ),
                              TextButton(
                                onPressed: _goToLogin,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                ),
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                    color: Color(0xFF1677FF),
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
      ),
    );
  }

  Widget _buildSecondPage(_OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
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
                  child: _buildRing(150, 0x0F1677FF),
                ),
                Positioned(
                  top: 36,
                  left: 30,
                  child: _buildFloatingChip(
                    icon: Icons.notifications_active_rounded,
                    size: 24,
                    color: const Color(0xFF1677FF),
                  ),
                ),
                Positioned(
                  bottom: 86,
                  left: 18,
                  child: _buildFloatingChip(
                    icon: Icons.calendar_today_rounded,
                    size: 22,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Positioned(
                  top: 36,
                  right: 30,
                  child: _buildFloatingChip(
                    icon: Icons.credit_card_rounded,
                    size: 24,
                    color: const Color(0xFF0F766E),
                  ),
                ),
                Positioned(
                  bottom: 86,
                  right: 18,
                  child: _buildFloatingChip(
                    icon: Icons.check_circle_rounded,
                    size: 24,
                    color: const Color(0xFF22C55E),
                  ),
                ),
                Container(
                  width: 250,
                  height: 388,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A0B1F4D),
                        blurRadius: 30,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Upcoming Payment',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B1F4D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1DB954)
                                          .withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.music_note_rounded,
                                        color: Color(0xFF1DB954),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Spotify Premium',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0B1F4D),
                                          ),
                                        ),
                                        const Text(
                                          '₹119 / month',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Active',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: const [
                                  Text(
                                    'Due on',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '25 May 2025',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0B1F4D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1677FF),
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 14,
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: Color(0xFF0B1F4D),
              ),
              children: [
                TextSpan(text: 'Get Reminded.\n'),
                TextSpan(
                  text: 'Stay Ahead.',
                  style: TextStyle(color: Color(0xFF1677FF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Smart reminders before every due date\nso you never miss a payment.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPage(_OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final phoneHeight = (availableHeight * 0.62).clamp(300.0, 460.0);
          final contentSpacing = availableHeight < 700 ? 8.0 : 10.0;

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
                      child: _buildGradientRing(120, const Color(0x1A1677FF)),
                    ),
                    Positioned(
                      bottom: 30,
                      right: -14,
                      child: _buildGradientRing(150, const Color(0x1A0F766E)),
                    ),
                    Positioned(
                      top: 40,
                      left: 24,
                      child: _buildFloatingChip(
                        icon: Icons.trending_up_rounded,
                        size: 22,
                        color: const Color(0xFF1677FF),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 24,
                      child: _buildFloatingChip(
                        icon: Icons.pie_chart_rounded,
                        size: 22,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                    Positioned(
                      bottom: 82,
                      left: 20,
                      child: _buildFloatingChip(
                        icon: Icons.wallet_rounded,
                        size: 22,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Positioned(
                      bottom: 82,
                      right: 20,
                      child: _buildFloatingChip(
                        icon: Icons.savings_rounded,
                        size: 22,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                    Container(
                      width: 250,
                      height: phoneHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A0B1F4D),
                            blurRadius: 30,
                            offset: Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          children: [
                            Container(
                              width: 92,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            SizedBox(height: contentSpacing),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1677FF),
                                    Color(0xFF3B82F6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Monthly Spending',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '₹3,247',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '+12% vs last month',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: contentSpacing),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: LayoutBuilder(
                                  builder: (context, listConstraints) {
                                    return SingleChildScrollView(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: listConstraints.maxHeight,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildAnalyticsRow('Netflix', '₹649'),
                                            const SizedBox(height: 8),
                                            _buildAnalyticsRow('Spotify', '₹119'),
                                            const SizedBox(height: 8),
                                            _buildAnalyticsRow('Amazon Prime', '₹299'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: contentSpacing),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Spending trend',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0B1F4D),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  LayoutBuilder(
                                    builder: (context, chartConstraints) {
                                      final barHeight = (chartConstraints.maxWidth * 0.18).clamp(28.0, 86.0);
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          _buildChartBar(
                                            barHeight,
                                            const Color(0xFF1677FF),
                                          ),
                                          const SizedBox(width: 6),
                                          _buildChartBar(
                                            barHeight + 20,
                                            const Color(0xFF3B82F6),
                                          ),
                                          const SizedBox(width: 6),
                                          _buildChartBar(
                                            barHeight + 36,
                                            const Color(0xFF60A5FA),
                                          ),
                                          const SizedBox(width: 6),
                                          _buildChartBar(
                                            barHeight + 14,
                                            const Color(0xFF1677FF),
                                          ),
                                          const SizedBox(width: 6),
                                          _buildChartBar(
                                            barHeight + 46,
                                            const Color(0xFF3B82F6),
                                          ),
                                          const SizedBox(width: 6),
                                          _buildChartBar(
                                            barHeight + 28,
                                            const Color(0xFF1677FF),
                                          ),
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: Color(0xFF0B1F4D),
                  ),
                  children: [
                    TextSpan(text: 'Understand.\n'),
                    TextSpan(
                      text: 'Save More.',
                      style: TextStyle(color: Color(0xFF1677FF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track your monthly and yearly subscription spending with beautiful insights and make smarter financial decisions.',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
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
                  child: _buildRing(140, 0x0F1677FF),
                ),
                Positioned(
                  top: 42,
                  child: _buildFloatingChip(
                    icon: Icons.notifications_active_rounded,
                    size: 44,
                    color: const Color(0xFF1677FF),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 140,
                  child: _buildFloatingChip(
                    icon: Icons.currency_rupee_rounded,
                    size: 40,
                    color: const Color(0xFF0B1F4D),
                  ),
                ),
                Positioned(
                  left: -4,
                  bottom: 88,
                  child: _buildFloatingChip(
                    icon: Icons.calendar_today_rounded,
                    size: 38,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 150,
                  child: _buildFloatingChip(
                    icon: Icons.insights_rounded,
                    size: 40,
                    color: const Color(0xFF1677FF),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 92,
                  child: _buildFloatingChip(
                    icon: Icons.shield_outlined,
                    size: 40,
                    color: const Color(0xFF0F766E),
                  ),
                ),
                Container(
                  width: 240,
                  height: 420,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A0B1F4D),
                        blurRadius: 30,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      children: [
                        Container(
                          height: 18,
                          width: 92,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              children: [
                                _buildSubscriptionCard(
                                  iconColor: const Color(0xFFFF3B30),
                                  title: 'Netflix',
                                  amount: '\$15.99',
                                ),
                                const SizedBox(height: 10),
                                _buildSubscriptionCard(
                                  iconColor: const Color(0xFF1DB954),
                                  title: 'Spotify',
                                  amount: '\$9.99',
                                ),
                                const SizedBox(height: 10),
                                _buildSubscriptionCard(
                                  iconColor: const Color(0xFFFF9900),
                                  title: 'Amazon Prime',
                                  amount: '\$8.99',
                                ),
                                const SizedBox(height: 10),
                                _buildSubscriptionCard(
                                  iconColor: const Color(0xFFFF0000),
                                  title: 'YouTube Premium',
                                  amount: '\$13.99',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: Color(0xFF0B1F4D),
              ),
              children: [
                TextSpan(text: 'Track. Manage.\n'),
                TextSpan(
                  text: 'Never Miss.',
                  style: TextStyle(color: Color(0xFF1677FF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'All your subscriptions in one place.\nStay on top, save more.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required Color iconColor,
    required String title,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B1F4D),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1F4D),
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF166534),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String title, String amount) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B1F4D),
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1677FF),
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
        color: color,
        borderRadius: BorderRadius.circular(999),
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
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
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
        border: Border.all(color: Color(colorValue).withValues(alpha: 0.65), width: 1.2),
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
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.03)],
          stops: const [0.2, 1.0],
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
  const _OnboardingPageData({
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

