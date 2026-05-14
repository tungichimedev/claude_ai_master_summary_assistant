import 'dart:async';

import 'package:ai_master/controllers/providers.dart';
import 'package:ai_master/controllers/states.dart';
import 'package:ai_master/controllers/subscription_controller.dart';
import 'package:ai_master/models/subscription_model.dart';
import 'package:ai_master/utils/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_services.dart';
import '../helpers/test_factories.dart';

/// Pumps the event queue to allow microtasks and stream callbacks to complete.
Future<void> pumpEventQueue({int times = 50}) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late MockPurchaseProvider mockPurchaseProvider;
  late ProviderContainer container;

  setUp(() {
    mockPurchaseProvider = MockPurchaseProvider();
    container = ProviderContainer(overrides: [
      purchaseProviderAdapter.overrideWithValue(mockPurchaseProvider),
    ]);
    // Keep a listener alive to prevent auto-dispose.
    container.listen(
      subscriptionControllerProvider,
      (prev, next) {},
      fireImmediately: true,
    );
  });

  tearDown(() {
    mockPurchaseProvider.dispose();
    container.dispose();
  });

  SubscriptionController notifier() {
    return container.read(subscriptionControllerProvider.notifier);
  }

  group('SubscriptionController', () {
    test('build() loads current subscription status (free tier)', () async {
      final sub =
          await container.read(subscriptionControllerProvider.future);

      expect(sub.tier, equals(SubscriptionTier.free));
      expect(sub.status, equals(SubscriptionStatus.expired));
    });

    test('build() loads pro subscription when customer has entitlement',
        () async {
      mockPurchaseProvider.customerInfoToReturn =
          TestFactories.createCustomerInfoJson();

      container.dispose();
      mockPurchaseProvider.dispose();
      mockPurchaseProvider = MockPurchaseProvider();
      mockPurchaseProvider.customerInfoToReturn =
          TestFactories.createCustomerInfoJson();

      container = ProviderContainer(overrides: [
        purchaseProviderAdapter.overrideWithValue(mockPurchaseProvider),
      ]);
      container.listen(
        subscriptionControllerProvider,
        (prev, next) {},
        fireImmediately: true,
      );

      final sub =
          await container.read(subscriptionControllerProvider.future);

      expect(sub.tier, equals(SubscriptionTier.pro));
      expect(sub.status, equals(SubscriptionStatus.active));
    });

    test('build() defaults to free tier on error', () async {
      mockPurchaseProvider.shouldThrow = true;

      container.dispose();
      container = ProviderContainer(overrides: [
        purchaseProviderAdapter.overrideWithValue(mockPurchaseProvider),
      ]);
      container.listen(
        subscriptionControllerProvider,
        (prev, next) {},
        fireImmediately: true,
      );

      final sub =
          await container.read(subscriptionControllerProvider.future);

      expect(sub.tier, equals(SubscriptionTier.free));
    });

    test('purchase(annual) - success updates state to pro', () async {
      await container.read(subscriptionControllerProvider.future);

      await notifier().purchase(PlanType.annual);

      final state = container.read(subscriptionControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.tier, equals(SubscriptionTier.pro));
      expect(mockPurchaseProvider.lastPurchasedPackageId,
          equals('pro_annual'));
    });

    test('purchase(monthly) - success updates state to pro', () async {
      await container.read(subscriptionControllerProvider.future);

      await notifier().purchase(PlanType.monthly);

      final state = container.read(subscriptionControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.tier, equals(SubscriptionTier.pro));
    });

    test('purchase - cancelled keeps current state', () async {
      await container.read(subscriptionControllerProvider.future);
      mockPurchaseProvider.shouldCancelPurchase = true;

      await notifier().purchase(PlanType.annual);

      final state = container.read(subscriptionControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.tier, equals(SubscriptionTier.free));
    });

    test('purchase - error sets error state', () async {
      await container.read(subscriptionControllerProvider.future);
      mockPurchaseProvider.shouldThrow = true;
      mockPurchaseProvider.errorToThrow = Exception('Payment processing failed');

      await notifier().purchase(PlanType.annual);

      final state = container.read(subscriptionControllerProvider);
      expect(state.hasError, isTrue);
    });

    test('restore - success updates state', () async {
      await container.read(subscriptionControllerProvider.future);

      mockPurchaseProvider.customerInfoToReturn =
          TestFactories.createCustomerInfoJson();

      await notifier().restore();

      final state = container.read(subscriptionControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.tier, equals(SubscriptionTier.pro));
    });

    test('restore - error sets error state', () async {
      await container.read(subscriptionControllerProvider.future);
      mockPurchaseProvider.shouldThrow = true;

      await notifier().restore();

      final state = container.read(subscriptionControllerProvider);
      expect(state.hasError, isTrue);
    });

    test('shouldShowPaywall returns true when free tier', () async {
      await container.read(subscriptionControllerProvider.future);

      expect(notifier().shouldShowPaywall, isTrue);
    });

    test('shouldShowPaywall returns false when pro', () async {
      container.dispose();
      mockPurchaseProvider.dispose();
      mockPurchaseProvider = MockPurchaseProvider();
      mockPurchaseProvider.customerInfoToReturn =
          TestFactories.createCustomerInfoJson();

      container = ProviderContainer(overrides: [
        purchaseProviderAdapter.overrideWithValue(mockPurchaseProvider),
      ]);
      container.listen(
        subscriptionControllerProvider,
        (prev, next) {},
        fireImmediately: true,
      );
      await container.read(subscriptionControllerProvider.future);

      expect(notifier().shouldShowPaywall, isFalse);
    });

    test('paywallType returns micro when tappedLockedFeature', () async {
      await container.read(subscriptionControllerProvider.future);

      final type = notifier().paywallType(
        hasUsedFreeSummary: false,
        hasReachedLimit: false,
        tappedLockedFeature: true,
      );
      expect(type, equals(PaywallType.micro));
    });

    test('paywallType returns hard when hasReachedLimit', () async {
      await container.read(subscriptionControllerProvider.future);

      final type = notifier().paywallType(
        hasUsedFreeSummary: true,
        hasReachedLimit: true,
        tappedLockedFeature: false,
      );
      expect(type, equals(PaywallType.hard));
    });

    test('paywallType returns soft when hasUsedFreeSummary', () async {
      await container.read(subscriptionControllerProvider.future);

      final type = notifier().paywallType(
        hasUsedFreeSummary: true,
        hasReachedLimit: false,
        tappedLockedFeature: false,
      );
      expect(type, equals(PaywallType.soft));
    });

    test('paywallType defaults to soft when no triggers', () async {
      await container.read(subscriptionControllerProvider.future);

      final type = notifier().paywallType(
        hasUsedFreeSummary: false,
        hasReachedLimit: false,
        tappedLockedFeature: false,
      );
      expect(type, equals(PaywallType.soft));
    });

    test('subscription stream updates state on renewal', () async {
      await container.read(subscriptionControllerProvider.future);

      // Simulate a subscription renewal via stream.
      mockPurchaseProvider.emitCustomerInfo(
        TestFactories.createCustomerInfoJson(),
      );

      await pumpEventQueue(times: 100);

      final state = container.read(subscriptionControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.tier, equals(SubscriptionTier.pro));
    });
  });
}
