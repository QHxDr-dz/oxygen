/// Domain entity for a gym subscription.
class SubscriptionEntity {
  final int id;
  final SubscriptionPlanEntity plan;
  final DateTime startDate;
  final DateTime endDate;
  final int daysLeft;
  final String status;

  const SubscriptionEntity({
    required this.id,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.daysLeft,
    required this.status,
  });

  bool get isOngoing => status == 'ongoing';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';

  double get progressFraction {
    final total = endDate.difference(startDate).inDays;
    if (total <= 0) return 1.0;
    final elapsed = total - daysLeft;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}

/// Domain entity for a subscription plan.
class SubscriptionPlanEntity {
  final int id;
  final String name;
  final double amount;
  final int days;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.days,
  });
}
