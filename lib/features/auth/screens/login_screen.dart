import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sanchora/features/navigation/main_navigation.dart';
import 'package:sanchora/features/profile/widgets/profile_info_section.dart';
import 'package:sanchora/features/auth/services/firebase_auth_service.dart';
import 'package:sanchora/features/auth/screens/complete_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();

  String? _phoneError;
  bool _isPhoneValid = false;

  bool _showOtp = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _otpVerified = false;
  String? _otpError;
  User? _loggedInUser;

  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 30;
  Timer? _countdownTimer;

  // Animations
  late AnimationController _heroAnimController;
  late Animation<double> _logoFadeAnim;
  late Animation<Offset> _logoSlideAnim;
  late Animation<double> _textFadeAnim;

  late AnimationController _otpAnimController;
  late Animation<double> _otpExpandAnim;
  late Animation<double> _otpFadeAnim;

  @override
  void initState() {
    super.initState();
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

    _otpAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _otpExpandAnim = CurvedAnimation(parent: _otpAnimController, curve: Curves.easeInOutCubic);
    _otpFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _otpAnimController, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );
  }

  void _setupListeners() {
    _phoneController.addListener(() {
      final text = _phoneController.text.replaceAll(RegExp(r'\D'), '');
      setState(() {
        _isPhoneValid = text.length == 10;
        if (_phoneError != null && _isPhoneValid) _phoneError = null;
      });
    });

    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(() {
        if (_otpError != null) {
          setState(() => _otpError = null);
        }
        final text = _otpControllers[i].text;
        if (text.isNotEmpty && i < 5) {
          _otpFocusNodes[i + 1].requestFocus();
        }
        _checkAutoVerify();
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    _countdownTimer?.cancel();
    _heroAnimController.dispose();
    _otpAnimController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendOtp() async {
    _phoneError = _isPhoneValid ? null : '10 digits required';

    if (!_isPhoneValid) {
      setState(() {});
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    final phone = '+91${_phoneController.text.replaceAll(RegExp(r'\D'), '')}';

    try {
      await FirebaseAuthService.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _handleAutoVerification(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isSendingOtp = false;
            _otpError = e.message ?? 'Verification failed';
          });
          if (!_showOtp && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_otpError!)),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isSendingOtp = false;
            _showOtp = true;
          });
          _otpAnimController.forward();
          _startCountdown();
          _otpFocusNodes[0].requestFocus();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() {
        _isSendingOtp = false;
        _otpError = e.toString();
      });
      if (!_showOtp && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_otpError!)),
        );
      }
    }
  }

  Future<void> _handleAutoVerification(PhoneAuthCredential credential) async {
    setState(() => _isVerifyingOtp = true);
    try {
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      await _finalizeLogin(userCred.user!);
    } catch (e) {
      setState(() {
        _isVerifyingOtp = false;
        _otpError = 'Auto-verification failed';
      });
    }
  }

  void _checkAutoVerify() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6 && !_isVerifyingOtp && !_otpVerified) {
      _verifyOtp(otp);
    }
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isVerifyingOtp = true;
      _otpError = null;
    });

    try {
      final userCred = await FirebaseAuthService.instance.verifyOTP(otp);
      await _finalizeLogin(userCred.user!);
    } catch (e) {
      setState(() {
        _isVerifyingOtp = false;
        _otpError = 'Invalid OTP. Please try again.';
      });
      // Clear OTP
      for (var c in _otpControllers) {
        c.clear();
      }
      _otpFocusNodes[0].requestFocus();
    }
  }

  Future<void> _finalizeLogin(User user) async {
    setState(() {
      _otpVerified = true;
      _loggedInUser = user;
      _isVerifyingOtp = false;
    });
  }

  Future<void> _handleContinue() async {
    if (_loggedInUser == null) return;
    
    setState(() => _isVerifyingOtp = true);

    try {
      final exists = await FirebaseAuthService.instance.checkUserExists(_loggedInUser!.uid);
      if (mounted) {
        if (exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompleteProfileScreen(
                user: _loggedInUser!,
                phone: '+91${_phoneController.text.replaceAll(RegExp(r'\D'), '')}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isVerifyingOtp = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to check user status.')),
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
                      SizedBox(height: (screenHeight * 0.08) - 20),
                      _buildHeroSection(theme, isDark),
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
                'Welcome to Sanchora',
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
                'One App. Every Subscription.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Securely sign in to manage all your subscriptions in one place.',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumInputCard(
            label: 'Mobile Number',
            icon: Icons.phone_rounded,
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            hintText: '+91 Enter 10-digit number',
            errorText: _phoneError,
            readOnly: _otpVerified,
            isVerified: _otpVerified,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),
          _buildOtpSection(theme),
          const SizedBox(height: 20),
          _buildPrimaryButton(theme),
        ],
      ),
    );
  }

  Widget _buildOtpSection(ThemeData theme) {
    return SizeTransition(
      sizeFactor: _otpExpandAnim,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _otpFadeAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(height: 32),
            Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Flexible(
                  child: Container(
                    height: 56,
                    constraints: const BoxConstraints(maxWidth: 48),
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 6) {
                          for (int i = 0; i < 6; i++) {
                            _otpControllers[i].text = value[i];
                          }
                          _otpFocusNodes[5].requestFocus();
                          _checkAutoVerify();
                          return;
                        }
                        if (value.length > 1) {
                          _otpControllers[index].text = value.substring(value.length - 1);
                        }
                        if (value.isNotEmpty && index < 5) {
                          _otpFocusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _otpFocusNodes[index - 1].requestFocus();
                        }
                        _checkAutoVerify();
                      },
                    ),
                  ),
                );
              }),
            ),
            if (_otpError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _otpError!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_otpVerified)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Verified successfully',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _resendCountdown > 0 ? 'Resend code in ' : 'Didn\'t receive code? ',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_resendCountdown > 0)
                    Text(
                      '0:${_resendCountdown.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _handleSendOtp,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(ThemeData theme) {
    if (!_showOtp) {
      return _buildButton(
        theme: theme,
        label: 'Send OTP',
        isLoading: _isSendingOtp,
        isEnabled: _isPhoneValid && !_isSendingOtp,
        onTap: _handleSendOtp,
      );
    }

    return _buildButton(
      theme: theme,
      label: 'Continue',
      isLoading: _isVerifyingOtp,
      isEnabled: _otpVerified && !_isVerifyingOtp,
      onTap: _handleContinue,
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
