import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/subscription_service.dart';
import 'package:ai_master/models/subscription_model.dart';
import 'package:ai_master/utils/exceptions.dart';

// =============================================================================
// Mock PurchaseProvider
// =============================================================================

class MockPurchaseProvider implements PurchaseProvider {
  bool initialized = false;
  String? identifiedUserId;
  Map<String, dynamic> _customerInfo = {};
  String? nextError;
  final StreamController<Map<String, dynamic>> _customerInfoController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Purchased package IDs.
  final List<String> purchasedPackages = [];

  /// Configure the customer info that will be returned.
  void setCustomerInfo(Map<String, dynamic> info) {
    _customerInfo = info;
  }

  void _checkError() {
    if (nextError != null) {
      final msg = nextError!;
      nextError = null;
      throw Exception(msg);
    }
  }

  @override
  Future<void> initialize(String apiKey) async {
    _checkError();
    initialized = true;
  }

  @override
  Future<void> identify(String userId) async {
    _checkError();
    identifiedUserId = userId;
  }

  @override
  Future<Map<String, dynamic>> getCustomerInfo() async {
    _checkError();
    return _customerInfo;
  }

  @override
  Future<Map<String, dynamic>> purchase(String packageId) async {
    _checkError();
    purchasedPackages.add(packageId);
    return _customerInfo;
  }

  @override
  Future<Map<String, dynamic>> restorePurchases() async {
    _checkError();
    return _customerInfo;
  }

  @override
  Stream<Map<String, dynamic>> get customerInfoStream =>
      _customerInfoController.stream;

  void emitCustomerInfo(Map<String, dynamic> info) {
    _customerInfoController.add(info);
  }

  void dispose() {
    _customerInfoController.close();
  }
}

// =============================================================================
// Test helpers
// =============================================================================

Map<String, dynamic> _freeCustomerInfo() => {
      'entitlements': <String, dynamic>{},
    };

Map<String, dynamic> _activeProInfo({
  String periodType = 'NORMAL',
  String? expirationDate,
}) =>
    {
      'entitlements': {
        'pro': {
          'isActive': true,
          'periodType': periodType,
          'expirationDate':
              expirationDate ?? '2027-01-15T00:00:00.000Z',
        },
      },
    };

Map<String, dynamic> _trialProInfo({String? expirationDate}) =>
    _activeProInfo(
      periodType: 'TRIAL',
      expirationDate: expirationDate ??
          DateTime.now().add(const Duration(days: 5)).toIso8601String(),
    );

Map<String, dynamic> _expiredTrialInfo() => _activeProInfo(
      periodType: 'TRIAL',
      expirationDate:
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    );

// =============================================================================
// Tests
// =============================================================================

void main() {
  late MockPurchaseProvider provider;
  late SubscriptionService service;

  setUp(() {
    provider = MockPurchaseProvider();
    service = SubscriptionService(provider: provider);
  });

  tearDown(() {
    provider.dispose();
  });

  // ---------------------------------------------------------------------------
  // initialize
  // ---------------------------------------------------------------------------

  group('initialize', () {
    test('initializes and identifies user', () async {
      await service.initialize(apiKey: 'test-key', userId: 'user-123');

      expect(provider.initialized, true);
      expect(provider.identifiedUserId, 'user-123');
    });

    test('throws PurchaseException on failure', () async {
      provider.nextError = 'init failed';
      expect(
        () => service.initialize(apiKey: 'key', userId: 'user'),
        throwsA(isA<PurchaseException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getSubscriptionStatus
  // ---------------------------------------------------------------------------

  group('getSubscriptionStatus', () {
    test('returns free tier for new user (no entitlements)', () async {
      provider.setCustomerInfo(_freeCustomerInfo());

      final sub = await service.getSubscriptionStatus();
      expect(sub.tier, SubscriptionTier.free);
      expect(sub.status, SubscriptionStatus.expired);
      expect(sub.hasProAccess, false);
    });

    test('returns pro tier for active subscriber', () async {
      provider.setCustomerInfo(_activeProInfo());

      final sub = await service.getSubscriptionStatus();
      expect(sub.tier, SubscriptionTier.pro);
      expect(sub.status, SubscriptionStatus.active);
      expect(sub.hasProAccess, true);
    });

    test('returns pro with trial status during trial', () async {
      provider.setCustomerInfo(_trialProInfo());

      final sub = await service.getSubscriptionStatus();
      expect(sub.tier, SubscriptionTier.pro);
      expect(sub.status, SubscriptionStatus.trial);
    });

    test('returns free when pro entitlement is not active', () async {
      provider.setCustomerInfo({
        'entitlements': {
          'pro': {'isActive': false},
        },
      });

      final sub = await service.getSubscriptionStatus();
      expect(sub.tier, SubscriptionTier.free);
    });

    test('throws PurchaseException on provider failure', () async {
      provider.nextError = 'fetch failed';
      expect(
        () => service.getSubscriptionStatus(),
        throwsA(isA<PurchaseException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // isTrialActive
  // ---------------------------------------------------------------------------

  group('isTrialActive', () {
    test('returns true during active trial', () async {
      provider.setCustomerInfo(_trialProInfo(
        expirationDate:
            DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      ));

      final result = await service.isTrialActive();
      expect(result, true);
    });

    test('returns false after trial expired', () async {
      provider.setCustomerInfo(_expiredTrialInfo());

      // The _mapCustomerInfo still sets status=trial and trialEndsAt,
      // but isTrialActive checks if now is before trialEndsAt.
      final result = await service.isTrialActive();
      expect(result, false);
    });

    test('returns false for free user (no trial)', () async {
      provider.setCustomerInfo(_freeCustomerInfo());

      final result = await service.isTrialActive();
      expect(result, false);
    });

    test('returns false for active paid (not trial)', () async {
      provider.setCustomerInfo(_activeProInfo(periodType: 'NORMAL'));

      final result = await service.isTrialActive();
      expect(result, false);
    });
  });

  // ---------------------------------------------------------------------------
  // trialDaysRemaining
  // ---------------------------------------------------------------------------

  group('trialDaysRemaining', () {
    test('returns correct days for active trial', () async {
      final fiveDaysLater = DateTime.now().add(const Duration(days: 5));
      provider.setCustomerInfo(_trialProInfo(
        expirationDate: fiveDaysLater.toIso8601String(),
      ));

      final days = await service.trialDaysRemaining();
      // Should be 4 or 5 depending on time of day.
      expect(days, greaterThanOrEqualTo(4));
      expect(days, lessThanOrEqualTo(5));
    });

    test('returns 0 for expired trial', () async {
      provider.setCustomerInfo(_expiredTrialInfo());

      final days = await service.trialDaysRemaining();
      expect(days, 0);
    });

    test('returns 0 for free user', () async {
      provider.setCustomerInfo(_freeCustomerInfo());

      final days = await service.trialDaysRemaining();
      expect(days, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // purchasePackage
  // ---------------------------------------------------------------------------

  group('purchasePackage', () {
    test('calls provider with correct package id for monthly', () async {
      await service.purchasePackage(PlanType.monthly);
      expect(provider.purchasedPackages, contains('pro_monthly'));
    });

    test('calls provider with correct package id for weekly', () async {
      await service.purchasePackage(PlanType.weekly);
      expect(provider.purchasedPackages, contains('pro_weekly'));
    });

    test('calls provider with correct package id for annual', () async {
      await service.purchasePackage(PlanType.annual);
      expect(provider.purchasedPackages, contains('pro_annual'));
    });

    test('throws PurchaseCancelledException when user cancels', () async {
      provider.nextError = 'userCancelled';
      expect(
        () => service.purchasePackage(PlanType.monthly),
        throwsA(isA<PurchaseCancelledException>()),
      );
    });

    test('throws PurchaseAlreadyActiveException when already purchased',
        () async {
      provider.nextError = 'ALREADY_PURCHASED';
      expect(
        () => service.purchasePackage(PlanType.monthly),
        throwsA(isA<PurchaseAlreadyActiveException>()),
      );
    });

    test('throws PurchaseException on generic failure', () async {
      provider.nextError = 'some-random-error';
      expect(
        () => service.purchasePackage(PlanType.monthly),
        throwsA(isA<PurchaseException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // restorePurchases
  // ---------------------------------------------------------------------------

  group('restorePurchases', () {
    test('completes successfully when provider succeeds', () async {
      await service.restorePurchases();
      // No exception = success.
    });

    test('throws PurchaseException on failure', () async {
      provider.nextError = 'restore failed';
      expect(
        () => service.restorePurchases(),
        throwsA(isA<PurchaseException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // isProUser
  // ---------------------------------------------------------------------------

  group('isProUser', () {
    test('returns true for active pro subscriber', () async {
      provider.setCustomerInfo(_activeProInfo());
      expect(await service.isProUser(), true);
    });

    test('returns false for free user', () async {
      provider.setCustomerInfo(_freeCustomerInfo());
      expect(await service.isProUser(), false);
    });

    test('returns true during active trial', () async {
      provider.setCustomerInfo(_trialProInfo());
      expect(await service.isProUser(), true);
    });
  });

  // ---------------------------------------------------------------------------
  // subscriptionChanges
  // ---------------------------------------------------------------------------

  group('subscriptionChanges', () {
    test('emits SubscriptionModel on customer info update', () async {
      final stream = service.subscriptionChanges;

      Future.microtask(
          () => provider.emitCustomerInfo(_activeProInfo()));

      final sub = await stream.first;
      expect(sub.tier, SubscriptionTier.pro);
      expect(sub.hasProAccess, true);
    });
  });
}
