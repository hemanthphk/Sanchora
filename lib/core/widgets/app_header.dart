import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? center;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.leading,
    this.center,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],

          Expanded(
            child: center != null
                ? Center(child: center)
                : Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),

          if (actions != null) ...[
            const SizedBox(width: 12),
            ...actions!,
          ],
        ],
      ),
    );
  }
}