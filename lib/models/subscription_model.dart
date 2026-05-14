import 'package:equatable/equatable.dart';

/// The user's subscription tier.
enum SubscriptionTier {
  free,
  pro;

  factory SubscriptionTier.fromJson(String value) {
    return SubscriptionTier.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SubscriptionTier.free,
    );
  }

  String toJson() => name;
}

/// Current status of the subscription.
enum SubscriptionStatus {
  active,
  trial,
  expired,
  cancelled;

  factory SubscriptionStatus.fromJson(String value) {
    return SubscriptionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SubscriptionStatus.expired,
    );
  }

  String toJson() => name;
}

/// Billing plan cadence.
enum PlanType {
  weekly,
  monthly,
  annual;

  factory PlanType.fromJson(String value) {
    return PlanType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PlanType.monthly,
    );
  }

  String toJson() => name;
}

/// Represents the user's current subscription state.
///
/// Computed getters [isTrialActive] and [daysLeftInTrial] derive trial
/// status from [trialEndsAt] so callers never need to do date math.
class SubscriptionModel extends Equatable {
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final PlanType? planType;
  final DateTime? expiresAt;
  final DateTime? trialEndsAt;

  const SubscriptionModel({
    this.tier = SubscriptionTier.free,
    this.status = SubscriptionStatus.expired,
    this.planType,
    this.expiresAt,
    this.trialEndsAt,
  });

  /// Whether the user is currently in an active free trial.
  bool get isTrialActive {
    if (status != SubscriptionStatus.trial || trialEndsAt == null) {
      return false;
    }
    return DateTime.now().isBefore(trialEndsAt!);
  }

  /// Days remaining in the trial period. Returns 0 if trial is inactive.
  int get daysLeftInTrial {
    if (!isTrialActive || trialEndsAt == null) return 0;
    return trialEndsAt!.difference(DateTime.now()).inDays;
  }

  /// Whether the user currently has Pro-level access (paid or trial).
  bool get hasProAccess =>
      tier == SubscriptionTier.pro &&
      (status == SubscriptionStatus.active || isTrialActive);

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      tier: SubscriptionTier.fromJson(json['tier'] as String? ?? 'free'),
      status: SubscriptionStatus.fromJson(
        json['status'] as String? ?? 'expired',
      ),
      planType: json['planType'] != null
          ? PlanType.fromJson(json['planType'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      trialEndsAt: json['trialEndsAt'] != null
          ? DateTime.parse(json['trialEndsAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier.toJson(),
      'status': status.toJson(),
      'planType': planType?.toJson(),
      'expiresAt': expiresAt?.toIso8601String(),
      'trialEndsAt': trialEndsAt?.toIso8601String(),
    };
  }

  SubscriptionModel copyWith({
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    PlanType? planType,
    DateTime? expiresAt,
    DateTime? trialEndsAt,
  }) {
    return SubscriptionModel(
      tier: tier ?? this.tier,
      status: status ?? this.status,
      planType: planType ?? this.planType,
      expiresAt: expiresAt ?? this.expiresAt,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
    );
  }

  @override
  List<Object?> get props => [
        tier,
        status,
        planType,
        expiresAt,
        trialEndsAt,
      ];
}
