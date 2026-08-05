import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/subscription_icon_registry.dart';

/// Centralized widget for rendering subscription brand icons.
/// Resolves the icon using [SubscriptionIconRegistry] and gracefully falls back
/// to an initial letter display when the asset is unavailable or fails to load.
class SubscriptionIcon extends StatelessWidget {
  const SubscriptionIcon({
    super.key,
    required this.iconIdentifier,
    required this.fallbackName,
    this.category,
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
  final String? category;
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
    final logoData = SubscriptionIconRegistry.getIcon(iconIdentifier ?? fallbackName);

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
        child: _buildImage(context, logoData),
      ),
    );
  }

  Widget _buildImage(BuildContext context, SubscriptionLogoData logoData) {
    if (logoData.type == LogoSourceType.network) {
      return CachedNetworkImage(
        imageUrl: logoData.path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        errorWidget: (context, url, error) => _buildFallback(context),
      );
    } else if (logoData.type == LogoSourceType.local) {
      return Image.asset(
        logoData.path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else {
      return _buildFallback(context);
    }
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    final cat = (category ?? 'Other').toLowerCase();

    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (cat) {
      case 'streaming':
        iconData = Icons.play_circle_fill_rounded;
        iconColor = const Color(0xFFEF4444); // Red
        bgColor = const Color(0xFFFEE2E2);
        break;
      case 'music':
        iconData = Icons.music_note_rounded;
        iconColor = const Color(0xFF10B981); // Green
        bgColor = const Color(0xFFD1FAE5);
        break;
      case 'gaming':
        iconData = Icons.sports_esports_rounded;
        iconColor = const Color(0xFF8B5CF6); // Purple
        bgColor = const Color(0xFFEDE9FE);
        break;
      case 'cloud storage':
      case 'cloud':
        iconData = Icons.cloud_rounded;
        iconColor = const Color(0xFF3B82F6); // Blue
        bgColor = const Color(0xFFDBEAFE);
        break;
      case 'design':
        iconData = Icons.palette_rounded;
        iconColor = const Color(0xFFF59E0B); // Amber
        bgColor = const Color(0xFFFEF3C7);
        break;
      case 'productivity':
        iconData = Icons.work_rounded;
        iconColor = const Color(0xFF0EA5E9); // Light Blue
        bgColor = const Color(0xFFE0F2FE);
        break;
      case 'education':
        iconData = Icons.school_rounded;
        iconColor = const Color(0xFF14B8A6); // Teal
        bgColor = const Color(0xFFCCFBF1);
        break;
      case 'finance':
        iconData = Icons.account_balance_wallet_rounded;
        iconColor = const Color(0xFFF59E0B); // Amber
        bgColor = const Color(0xFFFEF3C7);
        break;
      case 'shopping':
        iconData = Icons.shopping_bag_rounded;
        iconColor = const Color(0xFFEC4899); // Pink
        bgColor = const Color(0xFFFCE7F3);
        break;
      case 'food':
        iconData = Icons.restaurant_rounded;
        iconColor = const Color(0xFFF97316); // Orange
        bgColor = const Color(0xFFFFEDD5);
        break;
      case 'fitness':
        iconData = Icons.fitness_center_rounded;
        iconColor = const Color(0xFF10B981); // Green
        bgColor = const Color(0xFFD1FAE5);
        break;
      case 'security':
        iconData = Icons.security_rounded;
        iconColor = const Color(0xFF64748B); // Slate
        bgColor = const Color(0xFFF1F5F9);
        break;
      default:
        iconData = Icons.inventory_2_rounded;
        iconColor = theme.colorScheme.primary;
        bgColor = theme.colorScheme.primary.withValues(alpha: 0.1);
        break;
    }

    return Container(
      width: size,
      height: size,
      color: bgColor,
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: size * 0.5,
        ),
      ),
    );
  }
}
