import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  bool get hasLength => password.length >= 8 && password.length <= 64;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecial => password.contains(RegExp(r'[!@#\$&*~`%\^()_\-+={\[}\]\|\\:;\"<,>.?\/]'));

  int get strengthScore {
    int score = 0;
    if (hasLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumber) score++;
    if (hasSpecial) score++;
    return score;
  }

  String get strengthLabel {
    if (password.isEmpty) return 'None';
    if (strengthScore <= 2) return 'Weak';
    if (strengthScore <= 3) return 'Medium';
    if (strengthScore <= 4) return 'Strong';
    return 'Excellent';
  }

  Color get strengthColor {
    if (password.isEmpty) return Colors.transparent;
    if (strengthScore <= 2) return const Color(0xFFEF4444); // Red
    if (strengthScore <= 3) return const Color(0xFFF59E0B); // Orange
    if (strengthScore <= 4) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFF10B981); // Green
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFE5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: strengthColor == Colors.transparent 
                    ? (isDark ? Colors.white10 : const Color(0xFFF3F4F6))
                    : strengthColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                strengthLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: strengthColor == Colors.transparent 
                      ? theme.colorScheme.onSurfaceVariant 
                      : strengthColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 6,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: 6,
                width: constraints.maxWidth * (password.isEmpty ? 0 : strengthScore / 5),
                decoration: BoxDecoration(
                  color: strengthColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(width: itemWidth, child: _buildRequirement(context, '8 Characters', hasLength)),
                SizedBox(width: itemWidth, child: _buildRequirement(context, 'Uppercase', hasUppercase)),
                SizedBox(width: itemWidth, child: _buildRequirement(context, 'Lowercase', hasLowercase)),
                SizedBox(width: itemWidth, child: _buildRequirement(context, 'Number', hasNumber)),
                SizedBox(width: itemWidth, child: _buildRequirement(context, 'Special Character', hasSpecial)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRequirement(BuildContext context, String text, bool isMet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMet 
            ? const Color(0xFF10B981).withValues(alpha: 0.15) 
            : (isDark ? Colors.white10 : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_rounded,
            size: 14,
            color: isMet ? const Color(0xFF10B981) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isMet ? FontWeight.w600 : FontWeight.w500,
                color: isMet 
                    ? (isDark ? Colors.white : const Color(0xFF064E3B))
                    : theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
