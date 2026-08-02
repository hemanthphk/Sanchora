import 'package:flutter/material.dart';
import 'package:sanchora/core/widgets/app_header.dart';

class HelpFeedbackScreen extends StatelessWidget {
  const HelpFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Help & Feedback',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildActionItem(
                        context,
                        title: 'Contact Support',
                        icon: Icons.support_agent_rounded,
                      ),
                      _buildDivider(theme),
                      _buildActionItem(
                        context,
                        title: 'Send Feedback',
                        icon: Icons.feedback_rounded,
                      ),
                      _buildDivider(theme),
                      _buildActionItem(
                        context,
                        title: 'Report a Bug',
                        icon: Icons.bug_report_rounded,
                      ),
                      _buildDivider(theme),
                      _buildActionItem(
                        context,
                        title: 'FAQ',
                        icon: Icons.help_outline_rounded,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
    );
  }

  Widget _buildActionItem(BuildContext context, {
    required String title,
    required IconData icon,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {}, // Backend logic added later
      borderRadius: BorderRadius.vertical(
        top: title == 'Contact Support' ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 24),
          ],
        ),
      ),
    );
  }
}
