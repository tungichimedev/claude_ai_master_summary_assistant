import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/subscription_model.dart';

void main() {
  SubscriptionModel _createSubscription({
    SubscriptionTier tier = SubscriptionTier.free,
    SubscriptionStatus status = SubscriptionStatus.expired,
    PlanType? planType,
    DateTime? expiresAt,
    DateTime? trialEndsAt,
  }) {
    return SubscriptionModel(
      tier: tier,
      status: status,
      planType: planType,
      expiresAt: expiresAt,
      trialEndsAt: trialEndsAt,
    );
  }

  group('SubscriptionTier enum', () {
    test('fromJson returns correct values', () {
      expect(SubscriptionTier.fromJson('free'), SubscriptionTier.free);
      expect(SubscriptionTier.fromJson('pro'), SubscriptionTier.pro);
    });

    test('fromJson defaults to free for unknown', () {
      expect(SubscriptionTier.fromJson('enterprise'), SubscriptionTier.free);
    });

    test('toJson returns name', () {
      expect(SubscriptionTier.free.toJson(), 'free');
      expect(SubscriptionTier.pro.toJson(), 'pro');
    });
  });

  group('SubscriptionStatus enum', () {
    test('fromJson returns correct values', () {
      expect(SubscriptionStatus.fromJson('active'), SubscriptionStatus.active);
      expect(SubscriptionStatus.fromJson('trial'), SubscriptionStatus.trial);
      expect(
          SubscriptionStatus.fromJson('expired'), SubscriptionStatus.expired);
      expect(SubscriptionStatus.fromJson('cancelled'),
          SubscriptionStatus.cancelled);
    });

    test('fromJson defaults to expired for unknown', () {
      expect(SubscriptionStatus.fromJson('paused'), SubscriptionStatus.expired);
    });
  });

  group('PlanType enum', () {
    test('fromJson returns correct values', () {
      expect(PlanType.fromJson('weekly'), PlanType.weekly);
      expect(PlanType.fromJson('monthly'), PlanType.monthly);
      expect(PlanType.fromJson('annual'), PlanType.annual);
    });

    test('fromJson defaults to monthly for unknown', () {
      expect(PlanType.fromJson('biweekly'), PlanType.monthly);
    });
  });

  group('SubscriptionModel.fromJson', () {
    test('creates model with all fields present', () {
      final expires = DateTime(2025, 12, 31);
      final trialEnd = DateTime(2025, 7, 1);

      final json = {
        'tier': 'pro',
        'status': 'active',
        'planType': 'annual',
        'expiresAt': expires.toIso8601String(),
        'trialEndsAt': trialEnd.toIso8601String(),
      };

      final model = SubscriptionModel.fromJson(json);

      expect(model.tier, SubscriptionTier.pro);
      expect(model.status, SubscriptionStatus.active);
      expect(model.planType, PlanType.annual);
      expect(model.expiresAt, expires);
      expect(model.trialEndsAt, trialEnd);
    });

    test('applies defaults for missing fields', () {
      final model = SubscriptionModel.fromJson(<String, dynamic>{});

      expect(model.tier, SubscriptionTier.free);
      expect(model.status, SubscriptionStatus.expired);
      expect(model.planType, isNull);
      expect(model.expiresAt, isNull);
      expect(model.trialEndsAt, isNull);
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final original = _createSubscription(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.active,
        planType: PlanType.monthly,
        expiresAt: DateTime(2025, 12, 31),
        trialEndsAt: DateTime(2025, 7, 1),
      );
      final restored = SubscriptionModel.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('SubscriptionModel.toJson', () {
    test('serializes null optional fields as null', () {
      final model = _createSubscription();
      final json = model.toJson();

      expect(json['planType'], isNull);
      expect(json['expiresAt'], isNull);
      expect(json['trialEndsAt'], isNull);
    });
  });

  group('SubscriptionModel.copyWith', () {
    test('copies with no changes returns equal model', () {
      final model = _createSubscription();
      expect(model.copyWith(), equals(model));
    });

    test('copies with changed tier', () {
      final model = _createSubscription(tier: SubscriptionTier.free);
      final copy = model.copyWith(tier: SubscriptionTier.pro);

      expect(copy.tier, SubscriptionTier.pro);
      expect(copy.status, model.status);
    });

    test('copies with changed status', () {
      final model = _createSubscription(status: SubscriptionStatus.expired);
      final copy = model.copyWith(status: SubscriptionStatus.active);

      expect(copy.status, SubscriptionStatus.active);
    });
  });

  group('SubscriptionModel Equatable', () {
    test('two models with same values are equal', () {
      final a = _createSubscription();
      final b = _createSubscription();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two models with different tier are not equal', () {
      final a = _createSubscription(tier: SubscriptionTier.free);
      final b = _createSubscription(tier: SubscriptionTier.pro);

      expect(a, isNot(equals(b)));
    });
  });

  group('SubscriptionModel computed getters', () {
    test('isTrialActive is true when status is trial and trialEndsAt is future',
        () {
      final model = _createSubscription(
        status: SubscriptionStatus.trial,
        trialEndsAt: DateTime.now().add(const Duration(days: 5)),
      );

      expect(model.isTrialActive, isTrue);
    });

    test('isTrialActive is false when status is not trial', () {
      final model = _createSubscription(
        status: SubscriptionStatus.active,
        trialEndsAt: DateTime.now().add(const Duration(days: 5)),
      );

      expect(model.isTrialActive, isFalse);
    });

    test('isTrialActive is false when trialEndsAt is null', () {
      final model = _createSubscription(
        status: SubscriptionStatus.trial,
        trialEndsAt: null,
      );

      expect(model.isTrialActive, isFalse);
    });

    test('isTrialActive is false when trial has expired', () {
      final model = _createSubscription(
        status: SubscriptionStatus.trial,
        trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(model.isTrialActive, isFalse);
    });

    test('daysLeftInTrial returns positive days when trial is active', () {
      final model = _createSubscription(
        status: SubscriptionStatus.trial,
        trialEndsAt: DateTime.now().add(const Duration(days: 5)),
      );

      // Could be 4 or 5 depending on time-of-day rounding
      expect(model.daysLeftInTrial, greaterThanOrEqualTo(4));
      expect(model.daysLeftInTrial, lessThanOrEqualTo(5));
    });

    test('daysLeftInTrial returns 0 when trial is inactive', () {
      final model = _createSubscription(
        status: SubscriptionStatus.expired,
        trialEndsAt: DateTime.now().add(const Duration(days: 5)),
      );

      expect(model.daysLeftInTrial, 0);
    });

    test('daysLeftInTrial returns 0 when trial has expired', () {
      final model = _createSubscription(
        status: SubscriptionStatus.trial,
        trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(model.daysLeftInTrial, 0);
    });

    test('hasProAccess is true for active pro subscription', () {
      final model = _createSubscription(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.active,
      );

      expect(model.hasProAccess, isTrue);
    });

    test('hasProAccess is true for pro trial that is active', () {
      final model = _createSubscription(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.trial,
        trialEndsAt: DateTime.now().add(const Duration(days: 3)),
      );

      expect(model.hasProAccess, isTrue);
    });

    test('hasProAccess is false for free tier', () {
      final model = _createSubscription(
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
      );

      expect(model.hasProAccess, isFalse);
    });

    test('hasProAccess is false for expired pro subscription', () {
      final model = _createSubscription(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.expired,
      );

      expect(model.hasProAccess, isFalse);
    });

    test('hasProAccess is false for cancelled pro subscription', () {
      final model = _createSubscription(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.cancelled,
      );

      expect(model.hasProAccess, isFalse);
    });

    test('hasProAccess is false for pro trial that has expired', () {
      final model = _createSubscription(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.trial,
        trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(model.hasProAccess, isFalse);
    });
  });
}
