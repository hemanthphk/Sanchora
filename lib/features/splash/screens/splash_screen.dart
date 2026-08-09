import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanchora/features/navigation/main_navigation.dart';
import 'package:sanchora/features/auth/screens/verify_email_screen.dart';
import 'package:sanchora/features/auth/screens/login_screen.dart';
import 'package:sanchora/features/onboarding/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    Future.microtask(() async {
      await _controller.forward();

      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;

        if (!mounted) return;

        if (!isOnboardingCompleted) {
          _navigateTo(context, const OnboardingScreen());
          return;
        }

        var user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.reload();
          user = FirebaseAuth.instance.currentUser;
          
          if (!mounted) return;
          
          if (user != null && user.emailVerified) {
            _navigateTo(context, const MainNavigation());
          } else {
            _navigateTo(context, const VerifyEmailScreen());
          }
        } else {
          _navigateTo(context, const LoginScreen());
        }
      }
    });
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => screen,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final logoSize = (screenHeight * 0.44).clamp(250.0, 290.0);

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onDoubleTap: () async {
                          if (kDebugMode) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('isOnboardingCompleted');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('DEBUG: Onboarding reset')),
                              );
                            }
                          }
                        },
                        child: Image.asset(
                          'assets/images/sanchora_logo.png',
                          width: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sanchora',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'One App. Every Subscription.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 36,
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1677FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}

class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Text(
          'Next Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}