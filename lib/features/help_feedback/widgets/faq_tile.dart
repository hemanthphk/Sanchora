import 'package:flutter/material.dart';
import '../models/faq_item.dart';

class FaqTile extends StatefulWidget {
  final FaqItem item;
  final String id;
  final String? expandedId;
  final Function(String, bool) onExpansionChanged;

  const FaqTile({
    super.key,
    required this.item,
    required this.id,
    required this.expandedId,
    required this.onExpansionChanged,
  });

  @override
  State<FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile> {
  final ExpansibleController _controller = ExpansibleController();

  @override
  void didUpdateWidget(FaqTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expandedId != widget.id && _controller.isExpanded) {
      _controller.collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent, // Remove borders in expansion tile
        ),
        child: ExpansionTile(
          controller: _controller,
          onExpansionChanged: (expanded) {
            widget.onExpansionChanged(widget.id, expanded);
          },
          title: Text(
            widget.item.question,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          iconColor: theme.colorScheme.primary,
          collapsedIconColor: theme.colorScheme.onSurfaceVariant,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.answer,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
