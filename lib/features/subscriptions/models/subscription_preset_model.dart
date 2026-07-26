import 'package:flutter/material.dart';

class SubscriptionPresetModel {
  final String name;
  final String defaultCategory;
  final String defaultBillingCycle;

  // Future-ready optional fields
  final String? iconKey;
  final Color? brandColor;
  final String? website;
  final List<String>? ocrMapping;
  final List<String>? aiDetectionKeywords;

  const SubscriptionPresetModel({
    required this.name,
    required this.defaultCategory,
    required this.defaultBillingCycle,
    this.iconKey,
    this.brandColor,
    this.website,
    this.ocrMapping,
    this.aiDetectionKeywords,
  });
}
