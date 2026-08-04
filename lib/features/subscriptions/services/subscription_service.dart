import 'package:flutter/foundation.dart';
import '../models/subscription_model.dart';
import '../models/dashboard_summary.dart';
import 'dummy_subscriptions.dart';
import '../../notifications/services/notification_service.dart';

class SubscriptionService extends ChangeNotifier {
  SubscriptionService._internal() {
    _recalculateDashboardSummary();
  }

  static final SubscriptionService instance = SubscriptionService._internal();

  List<SubscriptionModel> get subscriptions => dummySubscriptions;

  late DashboardSummary _dashboardSummary;
  DashboardSummary get dashboardSummary => _dashboardSummary;

  List<SubscriptionModel> _upcomingRenewals = [];
  List<SubscriptionModel> get upcomingRenewals => _upcomingRenewals;

  void _recalculateDashboardSummary() {
    int activeSubscriptions = 0;
    int cancelledSubscriptions = 0;
    int freeTrials = 0;
    double monthlySpend = 0.0;
    double yearlySpend = 0.0;
    double totalSaved = 0.0;
    SubscriptionModel? highestSpendSubscription;
    double highestSpendAmount = 0.0;
    double lifetimeSpend = 0.0;

    final activeAndUpcoming = <SubscriptionModel>[];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var sub in dummySubscriptions) {
      if (sub.status == SubscriptionStatus.cancelled) {
        cancelledSubscriptions++;
        totalSaved += sub.currentPrice;
      } else if (sub.status == SubscriptionStatus.active || sub.status == SubscriptionStatus.upcoming) {
        activeSubscriptions++;
        activeAndUpcoming.add(sub);
        
        if (sub.nextRenewalDate.year == today.year && sub.nextRenewalDate.month == today.month) {
          monthlySpend += sub.currentPrice;
        }
        yearlySpend += sub.yearlyPrice;
        
        if (sub.isTrial || sub.name.toLowerCase().contains('trial') || sub.currentPrice == 0) {
          freeTrials++;
        }

        if (sub.monthlyPrice > highestSpendAmount) {
          highestSpendAmount = sub.monthlyPrice;
          highestSpendSubscription = sub;
        }
      }

      // Calculate lifetime spend for this subscription
      if (!sub.isTrial) {
        DateTime paymentDate = sub.startDate;
        // Count all payments strictly before 'now' (or exactly at now)
        while (paymentDate.isBefore(now) || paymentDate.isAtSameMomentAs(now)) {
          lifetimeSpend += sub.currentPrice;
          if (sub.billingCycle == BillingCycle.monthly) {
            paymentDate = DateTime(paymentDate.year, paymentDate.month + 1, paymentDate.day);
          } else {
            paymentDate = DateTime(paymentDate.year + 1, paymentDate.month, paymentDate.day);
          }
        }
      }
    }

    // Sort upcoming renewals
    activeAndUpcoming.sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
    _upcomingRenewals = activeAndUpcoming;
    
    // Calculate 7 days spending
    final Map<DateTime, double> spending = {};
    for (int i = 6; i >= 0; i--) {
      spending[today.subtract(Duration(days: i))] = 0.0;
    }

    for (var sub in activeAndUpcoming) {
      DateTime lastRenewal;
      if (sub.billingCycle == BillingCycle.monthly) {
        lastRenewal = DateTime(sub.nextRenewalDate.year, sub.nextRenewalDate.month - 1, sub.nextRenewalDate.day);
      } else {
        lastRenewal = DateTime(sub.nextRenewalDate.year - 1, sub.nextRenewalDate.month, sub.nextRenewalDate.day);
      }
      final startDate = DateTime(sub.startDate.year, sub.startDate.month, sub.startDate.day);
      
      if (spending.containsKey(lastRenewal)) {
        spending[lastRenewal] = spending[lastRenewal]! + sub.currentPrice;
      }
      if (spending.containsKey(startDate) && startDate != lastRenewal) {
        spending[startDate] = spending[startDate]! + sub.currentPrice;
      }
    }

    int upcomingPaymentsInNext7Days = 0;
    for (var sub in _upcomingRenewals) {
      final nextMidnight = DateTime(sub.nextRenewalDate.year, sub.nextRenewalDate.month, sub.nextRenewalDate.day);
      final diffDays = nextMidnight.difference(today).inDays;
      if (diffDays >= 0 && diffDays <= 7) {
        upcomingPaymentsInNext7Days++;
      }
    }

    _dashboardSummary = DashboardSummary(
      activeSubscriptions: activeSubscriptions,
      upcomingPayments: upcomingPaymentsInNext7Days,
      monthlySpend: monthlySpend,
      yearlySpend: yearlySpend,
      totalSaved: totalSaved,
      cancelledSubscriptions: cancelledSubscriptions,
      freeTrials: freeTrials,
      highestSpendSubscriptionName: highestSpendSubscription?.name ?? '',
      highestSpendAmount: highestSpendAmount,
      last7DaysSpending: spending,
      lifetimeSpend: lifetimeSpend,
    );
  }

  void addSubscription(SubscriptionModel subscription) {
    dummySubscriptions.insert(0, subscription);
    NotificationService.instance.scheduler.scheduleRemindersForSubscription(subscription);
    _recalculateDashboardSummary();
    notifyListeners();
  }

  void removeSubscription(SubscriptionModel subscription) {
    dummySubscriptions.removeWhere((sub) => sub.id == subscription.id || sub == subscription);
    NotificationService.instance.scheduler.cancelReminders(subscription.id);
    _recalculateDashboardSummary();
    notifyListeners();
  }

  void updateSubscription(SubscriptionModel subscription) {
    final index = dummySubscriptions.indexWhere((sub) => sub.id == subscription.id);
    if (index != -1) {
      dummySubscriptions[index] = subscription;
      NotificationService.instance.scheduler.cancelReminders(subscription.id);
      NotificationService.instance.scheduler.scheduleRemindersForSubscription(subscription);
      _recalculateDashboardSummary();
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
