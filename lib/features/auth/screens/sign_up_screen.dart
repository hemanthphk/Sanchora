import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanchora/features/navigation/main_navigation.dart';
import 'package:sanchora/features/auth/screens/verify_email_screen.dart';
import 'package:sanchora/features/profile/widgets/profile_info_section.dart';
import 'package:sanchora/features/auth/services/firebase_auth_service.dart';
import 'package:sanchora/features/auth/services/firestore_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  String? _errorText;
  String? _passwordErrorText;
  String? _emailErrorText;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // Animations
  late AnimationController _heroAnimController;
  late Animation<double> _logoFadeAnim;
  late Animation<Offset> _logoSlideAnim;
  late Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() => _emailErrorText = 'Email is required');
      return;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      setState(() => _emailErrorText = 'Enter a valid email address');
      return;
    }
    setState(() => _emailErrorText = null);
  }

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() => _passwordErrorText = 'Password is required');
      return;
    }
    if (value.length < 8) {
      setState(() => _passwordErrorText = 'Use at least 8 characters');
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      setState(() => _passwordErrorText = 'Add at least 1 uppercase letter');
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      setState(() => _passwordErrorText = 'Add at least 1 lowercase letter');
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      setState(() => _passwordErrorText = 'Include a number');
      return;
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) {
      setState(() => _passwordErrorText = 'Add a special character');
      return;
    }
    setState(() => _passwordErrorText = null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    
    _heroAnimController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Optional safety: re-check password validity
    if (password.isEmpty || password.length < 8 || 
        !RegExp(r'[A-Z]').hasMatch(password) || 
        !RegExp(r'[a-z]').hasMatch(password) || 
        !RegExp(r'[0-9]').hasMatch(password) || 
        !RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) {
      setState(() => _errorText = 'Invalid password.');
      return;
    }

    if (name.isEmpty || email.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorText = 'Please fill in all required fields.');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorText = 'Passwords do not match.');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorText = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final userCred = await FirebaseAuthService.instance.createUserWithEmailAndPassword(email, password);
      
      if (userCred.user != null) {
        await FirestoreService.instance.createUserProfile(
          user: userCred.user!, 
          name: name, 
          email: email,
          phone: phone.isNotEmpty ? phone : null,
        );
        
        await userCred.user!.sendEmailVerification();
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = e.message ?? 'Sign up failed. Please try again.';
      });
    } catch (e) {
      setState(() {
        _errorText = 'An unexpected error occurred.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorText = null;
    });

    try {
      final userCred = await FirebaseAuthService.instance.signInWithGoogle();
      
      if (userCred != null && userCred.user != null) {
        final exists = await FirestoreService.instance.checkUserExists(userCred.user!.uid);
        if (!exists) {
          await FirestoreService.instance.createUserProfile(
            user: userCred.user!, 
            name: userCred.user!.displayName ?? 'User', 
            email: userCred.user!.email ?? '',
            photoUrl: userCred.user!.photoURL,
          );
        }
        
        await userCred.user!.reload();
        if (mounted) {
          if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
              (route) => false,
            );
          }
        }
      } else {
        setState(() => _isGoogleLoading = false);
      }
    } catch (e) {
      setState(() {
        _errorText = 'Google Sign-in failed. Please try again.';
        _isGoogleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                      SizedBox(height: (screenHeight * 0.02)),
                      _buildHeroSection(theme),
                      SizedBox(height: screenHeight * 0.04),
                      _buildAuthCard(theme, isDark),
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

  Widget _buildHeroSection(ThemeData theme) {
    return Column(
      children: [
        SlideTransition(
          position: _logoSlideAnim,
          child: FadeTransition(
            opacity: _logoFadeAnim,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join Sanchora today.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
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
      child: Form(
        key: _formKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGoogleButton(theme),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),
          const SizedBox(height: 24),
          PremiumInputCard(
            label: 'Full Name',
            icon: Icons.person_rounded,
            controller: _nameController,
            focusNode: _nameFocus,
            keyboardType: TextInputType.name,
            hintText: 'Enter your full name',
            errorText: null,
          ),
          FormField<String>(
            initialValue: _emailController.text,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
              return null;
            },
            builder: (field) {
              return PremiumInputCard(
                label: 'Email',
                icon: Icons.email_rounded,
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                hintText: 'Enter your email',
                errorText: field.errorText ?? _emailErrorText,
                onChanged: (val) {
                  field.didChange(val);
                  _validateEmail(val);
                },
              );
            },
          ),
          PremiumInputCard(
            label: 'Phone Number (Optional)',
            icon: Icons.phone_rounded,
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            hintText: 'Enter your phone number',
            errorText: null,
          ),
          FormField<String>(
            initialValue: _passwordController.text,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 8) return 'Use at least 8 characters';
              if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Add at least 1 uppercase letter';
              if (!RegExp(r'[a-z]').hasMatch(value)) return 'Add at least 1 lowercase letter';
              if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include a number';
              if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) return 'Add a special character';
              return null;
            },
            builder: (field) {
              return PremiumInputCard(
                label: 'Password',
                icon: Icons.lock_rounded,
                controller: _passwordController,
                focusNode: _passwordFocus,
                keyboardType: TextInputType.visiblePassword,
                hintText: 'Create a password',
                errorText: field.errorText ?? _passwordErrorText,
                onChanged: (val) {
                  field.didChange(val);
                  _validatePassword(val);
                },
                obscureText: true,
              );
            },
          ),
            PremiumInputCard(
              label: 'Confirm Password',
              icon: Icons.lock_outline_rounded,
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              keyboardType: TextInputType.visiblePassword,
              hintText: 'Confirm your password',
              errorText: null,
              obscureText: true,
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            _buildPrimaryButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleButton(ThemeData theme) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isGoogleLoading || _isLoading ? null : _handleGoogleSignIn,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isGoogleLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                Icon(Icons.g_mobiledata_rounded, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(ThemeData theme) {
    final isEnabled = !_isLoading && !_isGoogleLoading;
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
          onTap: isEnabled ? _handleSignUp : null,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Create Account',
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
