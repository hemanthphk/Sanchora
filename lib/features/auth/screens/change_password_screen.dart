import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sanchora/core/widgets/sanchora_button.dart';
import 'package:sanchora/core/widgets/sanchora_page_header.dart';
import 'package:sanchora/features/auth/services/auth_service.dart';
import 'package:sanchora/features/auth/widgets/password_field.dart';
import 'package:sanchora/features/auth/widgets/password_strength_indicator.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_validate);
    _newPasswordController.addListener(_validate);
    _confirmPasswordController.addListener(_validate);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {}); // Rebuild to update validations and strength
  }

  bool _isNewPasswordValid() {
    final pwd = _newPasswordController.text;
    final hasLength = pwd.length >= 8 && pwd.length <= 64;
    final hasUppercase = pwd.contains(RegExp(r'[A-Z]'));
    final hasLowercase = pwd.contains(RegExp(r'[a-z]'));
    final hasNumber = pwd.contains(RegExp(r'[0-9]'));
    final hasSpecial = pwd.contains(RegExp(r'[!@#\$&*~`%\^()_\-+={\[}\]\|\\:;\"<,>.?\/]'));
    return hasLength && hasUppercase && hasLowercase && hasNumber && hasSpecial;
  }

  bool get _canSave {
    final currentValid = _currentPasswordController.text.isNotEmpty;
    final confirmValid = _confirmPasswordController.text == _newPasswordController.text && _confirmPasswordController.text.isNotEmpty;
    return currentValid && _isNewPasswordValid() && confirmValid && !_isLoading;
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot Password?'),
        content: const Text('This feature will be available once cloud authentication is enabled.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_canSave) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      await MockAuthService.instance.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text('Password updated successfully.')),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update password: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const SanchoraPageHeader(title: 'Change Password'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                physics: const BouncingScrollPhysics(),
                children: [
                  PasswordField(
                    label: 'Current Password',
                    hintText: 'Enter current password',
                    controller: _currentPasswordController,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    label: 'New Password',
                    hintText: 'Enter new password',
                    controller: _newPasswordController,
                  ),
                  const SizedBox(height: 16),
                  PasswordStrengthIndicator(password: _newPasswordController.text),
                  const SizedBox(height: 16),
                  PasswordField(
                    label: 'Confirm New Password',
                    hintText: 'Re-enter new password',
                    controller: _confirmPasswordController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildGlassmorphicBottomBar(theme, isDark),
    );
  }

  Widget _buildGlassmorphicBottomBar(ThemeData theme, bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding == 0 ? 20 : bottomPadding + 8),
          decoration: BoxDecoration(
            color: isDark 
                ? theme.scaffoldBackgroundColor.withValues(alpha: 0.75) 
                : theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.2) : const Color(0xFFE8E8E8).withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Opacity(
            opacity: _canSave ? 1.0 : 0.5,
            child: SanchoraButton(
              label: 'Save Password',
              isPrimary: true,
              isLoading: _isLoading,
              onPressed: _canSave ? _handleSave : null,
            ),
          ),
        ),
      ),
    );
  }
}
