import 'package:flutter/material.dart';

enum SubscriptionStatus { active, upcoming, expired }

class SubscriptionModel {
  final String id;
  final String name;
  final String category;
  final double amount;
  final String billingCycle;
  final DateTime nextPaymentDate;
  final SubscriptionStatus status;
  final IconData icon;
  final Color iconColor;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.billingCycle,
    required this.nextPaymentDate,
    required this.status,
    required this.icon,
    required this.iconColor,
  });

  // Temporary mock data for UI foundation
  static List<SubscriptionModel> get mockData => [
        SubscriptionModel(
          id: '1',
          name: 'Netflix',
          category: 'Entertainment',
          amount: 649.0,
          billingCycle: 'Monthly',
          nextPaymentDate: DateTime.now().add(const Duration(days: 2)),
          status: SubscriptionStatus.upcoming,
          icon: Icons.play_circle_fill_rounded,
          iconColor: const Color(0xFFFF3B30),
        ),
        SubscriptionModel(
          id: '2',
          name: 'Spotify Premium',
          category: 'Music',
          amount: 119.0,
          billingCycle: 'Monthly',
          nextPaymentDate: DateTime.now().add(const Duration(days: 15)),
          status: SubscriptionStatus.active,
          icon: Icons.music_note_rounded,
          iconColor: const Color(0xFF1DB954),
        ),
        SubscriptionModel(
          id: '3',
          name: 'Amazon Prime',
          category: 'Shopping',
          amount: 1499.0,
          billingCycle: 'Yearly',
          nextPaymentDate: DateTime.now().subtract(const Duration(days: 5)),
          status: SubscriptionStatus.expired,
          icon: Icons.shopping_bag_rounded,
          iconColor: const Color(0xFFFF9900),
        ),
        SubscriptionModel(
          id: '4',
          name: 'Figma Professional',
          category: 'Productivity',
          amount: 1200.0,
          billingCycle: 'Monthly',
          nextPaymentDate: DateTime.now().add(const Duration(days: 8)),
          status: SubscriptionStatus.active,
          icon: Icons.design_services_rounded,
          iconColor: const Color(0xFFF24E1E),
        ),
      ];
}