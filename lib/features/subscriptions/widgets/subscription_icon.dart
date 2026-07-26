import 'package:flutter/material.dart';
import 'package:sanchora/core/theme/app_text_styles.dart';
import '../services/subscription_icon_registry.dart';

/// Centralized widget for rendering subscription brand icons.
/// Resolves the icon using [SubscriptionIconRegistry] and gracefully falls back
/// to an initial letter display when the asset is unavailable or fails to load.
class SubscriptionIcon extends StatelessWidget {
  const SubscriptionIcon({
    super.key,
    required this.iconIdentifier,
    required this.fallbackName,
    this.size = 52,
    this.borderRadius = 14,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.border,
    this.boxShadow,
  });

  final String? iconIdentifier;
  final String fallbackName;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assetPath = SubscriptionIconRegistry.getIconUrl(iconIdentifier ?? fallbackName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    final initial = fallbackName.trim().isNotEmpty
        ? fallbackName.trim()[0].toUpperCase()
        : '?';

    return Center(
      child: Text(
        initial,
        style: textStyle ??
            AppTextStyles.sectionTitle.copyWith(
              color: textColor ?? theme.colorScheme.primary,
              fontSize: size * 0.4,
            ),
      ),
    );
  }
}
