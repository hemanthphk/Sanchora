import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumInputCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool isVerified;
  final bool obscureText;

  const PremiumInputCard({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.hintText,
    this.onChanged,
    this.errorText,
    this.focusNode,
    this.inputFormatters,
    this.readOnly = false,
    this.isVerified = false,
    this.obscureText = false,
  });

  @override
  State<PremiumInputCard> createState() => _PremiumInputCardState();
}

class _PremiumInputCardState extends State<PremiumInputCard> {
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_isFocused) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.errorText != null 
              ? theme.colorScheme.error.withValues(alpha: 0.8)
              : (_isFocused ? theme.colorScheme.primary.withValues(alpha: 0.5) : borderColor),
          width: widget.errorText != null ? 1.2 : 1.0,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.readOnly ? null : () {
            if (!_isFocused) {
              setState(() {
                _isFocused = true;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _focusNode.requestFocus();
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? theme.colorScheme.primary.withValues(alpha: 0.15) 
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      IgnorePointer(
                        ignoring: !_isFocused,
                        child: TextField(
                          key: const ValueKey('editing'),
                          controller: widget.controller,
                          focusNode: _focusNode,
                          keyboardType: widget.keyboardType,
                          obscureText: widget.obscureText,
                          onChanged: widget.onChanged,
                          inputFormatters: widget.inputFormatters,
                          readOnly: !_isFocused || widget.readOnly,
                          cursorColor: theme.colorScheme.primary,
                          cursorWidth: 2,
                          cursorRadius: const Radius.circular(2),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: !_isFocused && widget.controller.text.isEmpty
                                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                                : theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      if (widget.errorText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.errorText!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: widget.isVerified
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('verified'),
                          size: 18,
                          color: Colors.green.shade600,
                        )
                      : widget.readOnly
                          ? const SizedBox.shrink()
                          : Icon(
                              _isFocused ? Icons.check_rounded : Icons.edit_rounded,
                              key: ValueKey(_isFocused),
                              size: 18,
                              color: _isFocused 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumInfoCard extends StatelessWidget {
  final List<PremiumInfoRow> rows;

  const PremiumInfoCard({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    final List<Widget> children = [];
    for (int i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(
          Divider(
            height: 1,
            thickness: 1,
            color: borderColor.withValues(alpha: isDark ? 0.4 : 0.7),
            indent: 56,
            endIndent: 16,
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

class PremiumInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const PremiumInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}

class PremiumSelectorCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final String value;
  final String? subtitle;
  final String hintText;
  final Future<void> Function() onTap;

  const PremiumSelectorCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    this.subtitle,
    this.hintText = '',
    required this.onTap,
  });

  @override
  State<PremiumSelectorCard> createState() => _PremiumSelectorCardState();
}

class _PremiumSelectorCardState extends State<PremiumSelectorCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    final displayValue = widget.value.isEmpty ? widget.hintText : widget.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isFocused ? theme.colorScheme.primary.withValues(alpha: 0.5) : borderColor,
          width: 1.0,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            if (!_isFocused) {
              setState(() {
                _isFocused = true;
              });
              try {
                await widget.onTap();
              } finally {
                if (mounted) {
                  setState(() {
                    _isFocused = false;
                  });
                }
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? theme.colorScheme.primary.withValues(alpha: 0.15) 
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: double.infinity,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: displayValue,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: widget.value.isEmpty
                                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                                const TextSpan(text: '   '),
                                TextSpan(
                                  text: widget.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: _isFocused 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
