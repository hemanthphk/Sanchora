import 'package:flutter/material.dart';
import 'package:sanchora/features/auth/models/linked_account.dart';

class ConnectedAccountTile extends StatelessWidget {
  final LinkedAccount account;
  final bool isLoading;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const ConnectedAccountTile({
    super.key,
    required this.account,
    this.isLoading = false,
    required this.onConnect,
    required this.onDisconnect,
  });

  IconData _getProviderIcon() {
    switch (account.provider) {
      case AccountProvider.google:
        return Icons.g_mobiledata_rounded;
      case AccountProvider.apple:
        return Icons.apple_rounded;
      case AccountProvider.facebook:
        return Icons.facebook_rounded;
      case AccountProvider.github:
        return Icons.code_rounded; // Fallback
      case AccountProvider.microsoft:
        return Icons.window_rounded;
      case AccountProvider.phone:
        return Icons.phone_iphone_rounded;
    }
  }

  Color _getProviderColor(bool isDark) {
    if (!account.isConnected) {
      return isDark ? Colors.white30 : Colors.black26;
    }
    switch (account.provider) {
      case AccountProvider.google:
        return const Color(0xFFDB4437);
      case AccountProvider.apple:
        return isDark ? Colors.white : Colors.black;
      case AccountProvider.facebook:
        return const Color(0xFF1877F2);
      case AccountProvider.github:
        return isDark ? Colors.white : const Color(0xFF24292F);
      case AccountProvider.microsoft:
        return const Color(0xFF00A4EF);
      case AccountProvider.phone:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getProviderColor(isDark).withValues(alpha: account.isConnected ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(
                _getProviderIcon(),
                size: 28,
                color: _getProviderColor(isDark),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.provider.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (account.isPrimary) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Primary Login',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    account.isConnected ? 'Connected' : 'Not Connected',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: account.isConnected 
                          ? const Color(0xFF10B981) 
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (account.isConnected) {
      return TextButton(
        onPressed: onDisconnect,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size.zero,
        ),
        child: const Text(
          'Disconnect',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }

    return TextButton(
      onPressed: onConnect,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
      ),
      child: const Text(
        'Connect',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
