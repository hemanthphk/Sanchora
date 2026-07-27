import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
          color: Color(0xFFEF4444),
        ),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFEF4444),
            letterSpacing: -0.2,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.18 : 0.08),
          foregroundColor: const Color(0xFFEF4444),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.35 : 0.2),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
