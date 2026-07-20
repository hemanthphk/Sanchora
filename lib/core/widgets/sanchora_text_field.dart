import 'package:flutter/material.dart';

class SanchoraTextField extends StatelessWidget {
  const SanchoraTextField({
    super.key,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
