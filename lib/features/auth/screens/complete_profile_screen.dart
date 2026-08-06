import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanchora/features/navigation/main_navigation.dart';
import 'package:sanchora/features/profile/widgets/profile_info_section.dart';
import 'package:sanchora/features/auth/services/firebase_auth_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User user;
  final String phone;

  const CompleteProfileScreen({
    super.key,
    required this.user,
    required this.phone,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  String? _nameError;
  String? _emailError;

  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isSaving = false;

  // Animations
  late AnimationController _heroAnimController;
  late Animation<double> _logoFadeAnim;
  late Animation<Offset> _logoSlideAnim;
  late Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phone;
    _setupAnimations();
    _setupListeners();
  }

  void _setupAnimations() {
    _heroAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnimController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _logoSlideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _heroAnimController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );

    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnimController, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );

    _heroAnimController.forward();
  }

  void _setupListeners() {
    _nameController.addListener(() {
      final text = _nameController.text.trim();
      setState(() {
        _isNameValid = text.length >= 3;
        if (_nameError != null && _isNameValid) _nameError = null;
      });
    });

    _emailController.addListener(() {
      final text = _emailController.text.trim();
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      setState(() {
        _isEmailValid = emailRegex.hasMatch(text);
        if (_emailError != null && _isEmailValid) _emailError = null;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _heroAnimController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    _nameError = _isNameValid ? null : 'Minimum 3 characters required';
    _emailError = _isEmailValid ? null : 'Valid email required';

    if (!_isNameValid || !_isEmailValid) {
      setState(() {});
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseAuthService.instance.createUserProfile(
        user: widget.user,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: widget.phone,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.08),
                      _buildHeroSection(theme, isDark),
                      SizedBox(height: screenHeight * 0.04),
                      _buildProfileCard(theme, isDark),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        SlideTransition(
          position: _logoSlideAnim,
          child: FadeTransition(
            opacity: _logoFadeAnim,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/sanchora_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: _textFadeAnim,
          child: Column(
            children: [
              Text(
                'Complete Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Tell us a little bit about yourself to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumInputCard(
            label: 'Full Name',
            icon: Icons.person_rounded,
            controller: _nameController,
            focusNode: _nameFocus,
            hintText: 'Enter your full name',
            errorText: _nameError,
          ),
          PremiumInputCard(
            label: 'Email Address',
            icon: Icons.email_rounded,
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            hintText: 'Enter your email address',
            errorText: _emailError,
          ),
          // Read-only Phone Number
          AbsorbPointer(
            child: PremiumInputCard(
              label: 'Mobile Number',
              icon: Icons.phone_rounded,
              controller: _phoneController,
              hintText: 'Phone Number',
              errorText: null,
            ),
          ),
          const SizedBox(height: 24),
          _buildButton(
            theme: theme,
            label: 'Create Account',
            isLoading: _isSaving,
            isEnabled: _isNameValid && _isEmailValid && !_isSaving,
            onTap: _handleCreateAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required ThemeData theme,
    required String label,
    required bool isLoading,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isEnabled
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              )
            : null,
        color: isEnabled ? null : theme.disabledColor.withValues(alpha: 0.1),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isEnabled ? onTap : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? Colors.white : theme.disabledColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
