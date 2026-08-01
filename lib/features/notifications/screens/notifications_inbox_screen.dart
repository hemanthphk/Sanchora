import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notification_settings_screen.dart';
import '../services/notification_history_service.dart';
import '../models/notification_message.dart';

class NotificationsInboxScreen extends StatelessWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = NotificationHistoryService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () => service.markAllAsRead(),
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
            tooltip: 'Notification Settings',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: service,
        builder: (context, _) {
          if (service.notifications.isEmpty) {
            return _buildEmptyState(context, theme);
          }
          return _buildNotificationList(context, theme, service);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "No notifications yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "We'll notify you about subscription renewals, free trials and important updates.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, ThemeData theme, NotificationHistoryService service) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        if (service.todayNotifications.isNotEmpty) ...[
          _buildGroupHeader('Today', theme),
          ...service.todayNotifications.map((msg) => _buildNotificationTile(context, theme, service, msg)),
          const SizedBox(height: 24),
        ],
        if (service.yesterdayNotifications.isNotEmpty) ...[
          _buildGroupHeader('Yesterday', theme),
          ...service.yesterdayNotifications.map((msg) => _buildNotificationTile(context, theme, service, msg)),
          const SizedBox(height: 24),
        ],
        if (service.earlierNotifications.isNotEmpty) ...[
          _buildGroupHeader('Earlier', theme),
          ...service.earlierNotifications.map((msg) => _buildNotificationTile(context, theme, service, msg)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildGroupHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, ThemeData theme, NotificationHistoryService service, NotificationMessage msg) {
    return InkWell(
      onTap: () {
        service.markAsRead(msg.id);
        // Deep linking implementation placeholder
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: msg.isRead 
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: msg.iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(msg.typeIcon, color: msg.iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          msg.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: msg.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (!msg.isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1677FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat.jm().format(msg.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
