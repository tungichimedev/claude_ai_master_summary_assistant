import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription_model.dart';
import '../utils/exceptions.dart';
import 'providers.dart';
import 'states.dart';

/// Controller for subscription state, purchase flows, and paywall logic.
class SubscriptionController
    extends AutoDisposeAsyncNotifier<SubscriptionModel> {
  @override
  Future<SubscriptionModel> build() async {
    try {
      final service = ref.read(subscriptionServiceProvider);
      final sub = await service.getSubscriptionStatus();

      // Listen for real-time subscription changes (renewal, expiry).
      final stream = service.subscriptionChanges.listen((updated) {
        state = AsyncData(updated);
      });
      ref.onDispose(stream.cancel);

      return sub;
    } catch (e) {
      // Default to free tier on error so the app remains usable.
      return const SubscriptionModel();
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Start the purchase flow for the given [plan].
  Future<void> purchase(PlanType plan) async {
    try {
      final service = ref.read(subscriptionServiceProvider);
      await service.purchasePackage(plan);
      // Refresh state after purchase.
      final updated = await service.getSubscriptionStatus();
      state = AsyncData(updated);
    } on PurchaseCancelledException {
      // User cancelled — no error, keep current state.
      return;
    } catch (e) {
      state = AsyncError(
        e is AppException ? e : UnexpectedException(e.toString(), e),
        StackTrace.current,
      );
    }
  }

  /// Restore previous purchases.
  Future<void> restore() async {
    try {
      final service = ref.read(subscriptionServiceProvider);
      await service.restorePurchases();
      final updated = await service.getSubscriptionStatus();
      state = AsyncData(updated);
    } catch (e) {
      state = AsyncError(
        e is AppException ? e : UnexpectedException(e.toString(), e),
        StackTrace.current,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Paywall logic
  // ---------------------------------------------------------------------------

  /// Whether any paywall should be shown to the current user.
  ///
  /// Returns true for free-tier users who have exhausted their daily limit.
  bool get shouldShowPaywall {
    final sub = state.valueOrNull ?? const SubscriptionModel();
    return sub.tier == SubscriptionTier.free;
  }

  /// Determine which paywall variant to show based on context.
  ///
  /// - [soft]: after first successful summary (dismissible)
  /// - [hard]: when the daily free limit is hit (non-dismissible)
  /// - [micro]: when tapping a locked feature (contextual bottom sheet)
  PaywallType paywallType({
    required bool hasUsedFreeSummary,
    required bool hasReachedLimit,
    required bool tappedLockedFeature,
  }) {
    if (tappedLockedFeature) return PaywallType.micro;
    if (hasReachedLimit) return PaywallType.hard;
    if (hasUsedFreeSummary) return PaywallType.soft;
    return PaywallType.soft;
  }
}
