import '../../domain/entities/subscription_entity.dart';

/// Data model for a subscription.
class SubscriptionModel {
  final int id;
  final SubscriptionPlanModel plan;
  final String startDate;
  final String endDate;
  final int daysLeft;
  final String status;

  const SubscriptionModel({
    required this.id,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.daysLeft,
    required this.status,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    // plan can be a string (dashboard) or an object (subscription endpoint)
    final planData = json['plan'];
    SubscriptionPlanModel planModel;
    if (planData is Map<String, dynamic>) {
      planModel = SubscriptionPlanModel.fromJson(planData);
    } else {
      planModel = SubscriptionPlanModel(
        id: 0,
        name: planData?.toString() ?? 'Plan',
        amount: 0,
        days: 30,
      );
    }

    return SubscriptionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      plan: planModel,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      daysLeft: (json['days_left'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'ongoing',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'plan': plan.toJson(),
    'start_date': startDate,
    'end_date': endDate,
    'days_left': daysLeft,
    'status': status,
  };

  SubscriptionEntity toEntity() {
    DateTime parsedStart;
    DateTime parsedEnd;
    try {
      parsedStart = DateTime.parse(startDate);
    } catch (_) {
      parsedStart = DateTime.now();
    }
    try {
      parsedEnd = DateTime.parse(endDate);
    } catch (_) {
      parsedEnd = DateTime.now().add(const Duration(days: 30));
    }
    return SubscriptionEntity(
      id: id,
      plan: plan.toEntity(),
      startDate: parsedStart,
      endDate: parsedEnd,
      daysLeft: daysLeft,
      status: status,
    );
  }
}

/// Data model for a subscription plan.
class SubscriptionPlanModel {
  final int id;
  final String name;
  final double amount;
  final int days;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.days,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Plan',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      days: (json['days'] as num?)?.toInt() ?? 30,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'days': days,
  };

  SubscriptionPlanEntity toEntity() =>
      SubscriptionPlanEntity(id: id, name: name, amount: amount, days: days);
}
