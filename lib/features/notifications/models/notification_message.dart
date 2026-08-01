import 'package:flutter/material.dart';

class NotificationMessage {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final IconData typeIcon;
  final Color iconColor;
  final String? subscriptionId;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.typeIcon,
    required this.iconColor,
    this.isRead = false,
    this.subscriptionId,
  });

  NotificationMessage copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? isRead,
    IconData? typeIcon,
    Color? iconColor,
    String? subscriptionId,
  }) {
    return NotificationMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      typeIcon: typeIcon ?? this.typeIcon,
      iconColor: iconColor ?? this.iconColor,
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }
}
