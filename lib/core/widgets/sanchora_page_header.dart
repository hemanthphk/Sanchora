import 'package:flutter/material.dart';

class SanchoraPageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SanchoraPageHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      titleSpacing: 4.0, // Reduced spacing between back button and title by ~12px from default 16
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
