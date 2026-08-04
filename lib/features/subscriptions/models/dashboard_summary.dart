import 'package:flutter/foundation.dart';

@immutable
class DashboardSummary {
  final int activeSubscriptions;
  final int upcomingPayments;
  final double monthlySpend;
  final double yearlySpend;
  final double totalSaved;
  final int cancelledSubscriptions;
  final int freeTrials;
  final String highestSpendSubscriptionName;
  final double highestSpendAmount;
  final Map<DateTime, double> last7DaysSpending;
  final double lifetimeSpend;

  const DashboardSummary({
    this.activeSubscriptions = 0,
    this.upcomingPayments = 0,
    this.monthlySpend = 0.0,
    this.yearlySpend = 0.0,
    this.totalSaved = 0.0,
    this.cancelledSubscriptions = 0,
    this.freeTrials = 0,
    this.highestSpendSubscriptionName = '',
    this.highestSpendAmount = 0.0,
    this.last7DaysSpending = const {},
    this.lifetimeSpend = 0.0,
  });

  DashboardSummary copyWith({
    int? activeSubscriptions,
    int? upcomingPayments,
    double? monthlySpend,
    double? yearlySpend,
    double? totalSaved,
    int? cancelledSubscriptions,
    int? freeTrials,
    String? highestSpendSubscriptionName,
    double? highestSpendAmount,
    Map<DateTime, double>? last7DaysSpending,
    double? lifetimeSpend,
  }) {
    return DashboardSummary(
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      upcomingPayments: upcomingPayments ?? this.upcomingPayments,
      monthlySpend: monthlySpend ?? this.monthlySpend,
      yearlySpend: yearlySpend ?? this.yearlySpend,
      totalSaved: totalSaved ?? this.totalSaved,
      cancelledSubscriptions: cancelledSubscriptions ?? this.cancelledSubscriptions,
      freeTrials: freeTrials ?? this.freeTrials,
      highestSpendSubscriptionName: highestSpendSubscriptionName ?? this.highestSpendSubscriptionName,
      highestSpendAmount: highestSpendAmount ?? this.highestSpendAmount,
      last7DaysSpending: last7DaysSpending ?? this.last7DaysSpending,
      lifetimeSpend: lifetimeSpend ?? this.lifetimeSpend,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardSummary &&
        other.activeSubscriptions == activeSubscriptions &&
        other.upcomingPayments == upcomingPayments &&
        other.monthlySpend == monthlySpend &&
        other.yearlySpend == yearlySpend &&
        other.totalSaved == totalSaved &&
        other.cancelledSubscriptions == cancelledSubscriptions &&
        other.freeTrials == freeTrials &&
        other.highestSpendSubscriptionName == highestSpendSubscriptionName &&
        other.highestSpendAmount == highestSpendAmount &&
        mapEquals(other.last7DaysSpending, last7DaysSpending) &&
        other.lifetimeSpend == lifetimeSpend;
  }

  @override
  int get hashCode {
    return activeSubscriptions.hashCode ^
        upcomingPayments.hashCode ^
        monthlySpend.hashCode ^
        yearlySpend.hashCode ^
        totalSaved.hashCode ^
        cancelledSubscriptions.hashCode ^
        freeTrials.hashCode ^
        highestSpendSubscriptionName.hashCode ^
        highestSpendAmount.hashCode ^
        last7DaysSpending.hashCode ^
        lifetimeSpend.hashCode;
  }
}
