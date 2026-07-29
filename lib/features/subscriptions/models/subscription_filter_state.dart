import 'package:sanchora/features/subscriptions/models/subscription_model.dart';

class SubscriptionFilterState {
  final String? category;
  final BillingCycle? billingCycle;

  const SubscriptionFilterState({
    this.category,
    this.billingCycle,
  });

  SubscriptionFilterState copyWith({
    String? category,
    bool clearCategory = false,
    BillingCycle? billingCycle,
    bool clearBillingCycle = false,
  }) {
    return SubscriptionFilterState(
      category: clearCategory ? null : (category ?? this.category),
      billingCycle: clearBillingCycle ? null : (billingCycle ?? this.billingCycle),
    );
  }

  bool get isActive => category != null || billingCycle != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SubscriptionFilterState &&
      other.category == category &&
      other.billingCycle == billingCycle;
  }

  @override
  int get hashCode => category.hashCode ^ billingCycle.hashCode;
}
