import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    this.title,
    required this.children,
    this.showDividers = true,
  });

  final String? title;
  final List<Widget> children;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    final List<Widget> columnChildren = [];
    for (int i = 0; i < children.length; i++) {
      columnChildren.add(children[i]);
      if (showDividers && i < children.length - 1) {
        columnChildren.add(
          Divider(
            height: 1,
            thickness: 1,
            color: borderColor.withValues(alpha: isDark ? 0.4 : 0.7),
            indent: 72,
            endIndent: 16,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: columnChildren,
            ),
          ),
        ),
      ],
    );
  }
}
