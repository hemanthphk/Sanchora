import '../data/subscription_presets.dart';
import '../models/subscription_preset_model.dart';

class SubscriptionPresetService {
  const SubscriptionPresetService();

  List<SubscriptionPresetModel> getAllPresets() => subscriptionPresets;

  List<SubscriptionPresetModel> searchPresets(String query) {
    if (query.trim().isEmpty) return subscriptionPresets;
    final lowerQuery = query.trim().toLowerCase();
    return subscriptionPresets.where((preset) {
      if (preset.name.toLowerCase().contains(lowerQuery)) return true;
      if (preset.aiDetectionKeywords != null) {
        return preset.aiDetectionKeywords!.any((kw) => kw.toLowerCase().contains(lowerQuery));
      }
      return false;
    }).toList();
  }

  SubscriptionPresetModel? findPresetByName(String name) {
    final lowerName = name.trim().toLowerCase();
    for (final preset in subscriptionPresets) {
      if (preset.name.toLowerCase() == lowerName) return preset;
    }
    return null;
  }
}
