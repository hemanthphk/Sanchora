import 'package:flutter/foundation.dart';
import '../models/subscription_model.dart';
import 'dummy_subscriptions.dart';

class SubscriptionService extends ChangeNotifier {
  SubscriptionService._internal();

  static final SubscriptionService instance = SubscriptionService._internal();

  List<SubscriptionModel> get subscriptions => dummySubscriptions;

  void addSubscription(SubscriptionModel subscription) {
    dummySubscriptions.insert(0, subscription);
    notifyListeners();
  }

  void removeSubscription(SubscriptionModel subscription) {
    dummySubscriptions.removeWhere((sub) => sub.id == subscription.id || sub == subscription);
    notifyListeners();
  }

  void updateSubscription(SubscriptionModel subscription) {
    final index = dummySubscriptions.indexWhere((sub) => sub.id == subscription.id);
    if (index != -1) {
      dummySubscriptions[index] = subscription;
      notifyListeners();
    }
  }

  bool isDuplicateName(String name, {String? excludeId}) {
    return dummySubscriptions.any((sub) {
      if (excludeId != null && sub.id == excludeId) return false;
      return sub.name.trim().toLowerCase() == name.trim().toLowerCase();
    });
  }
}

final subscriptionService = SubscriptionService.instance;
