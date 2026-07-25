enum BillingCycle {
  monthly,
  yearly,
}

enum SubscriptionStatus {
  active,
  upcoming,
  expired,
}

class SubscriptionModel {
  final String id;
  final String name;
  final String category;
  final double monthlyPrice;
  final double yearlyPrice;
  final BillingCycle billingCycle;
  final DateTime nextRenewalDate;
  final SubscriptionStatus status;
  final String iconUrl;
  final bool hasReminder;
  final String? notes;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.billingCycle,
    required this.nextRenewalDate,
    required this.status,
    required this.iconUrl,
    this.hasReminder = false,
    this.notes,
  });

  double get currentPrice => billingCycle == BillingCycle.monthly ? monthlyPrice : yearlyPrice;
}
