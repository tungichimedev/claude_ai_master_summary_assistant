import 'dart:async';

import '../models/subscription_model.dart';
import '../utils/exceptions.dart';

/// Abstract interface for the RevenueCat SDK so this service stays pure Dart.
abstract class PurchaseProvider {
  /// Initialise the purchases SDK with the API key.
  Future<void> initialize(String apiKey);

  /// Identify the user by their Firebase UID.
  Future<void> identify(String userId);

  /// Fetch the current customer info as a raw map.
  Future<Map<String, dynamic>> getCustomerInfo();

  /// Start a purchase flow for the given package identifier.
  Future<Map<String, dynamic>> purchase(String packageId);

  /// Restore previous purchases.
  Future<Map<String, dynamic>> restorePurchases();

  /// Stream of customer-info updates (e.g. renewals, expirations).
  Stream<Map<String, dynamic>> get customerInfoStream;
}

/// Maps RevenueCat package identifiers to our plan types.
const _planPackageIds = {
  PlanType.weekly: 'pro_weekly',
  PlanType.monthly: 'pro_monthly',
  PlanType.annual: 'pro_annual',
};

/// Service for managing in-app subscriptions via RevenueCat.
///
/// Pure Dart — depends on [PurchaseProvider] abstraction.
class SubscriptionService {
  final PurchaseProvider _provider;

  SubscriptionService({required PurchaseProvider provider})
      : _provider = provider;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialise RevenueCat with the given [apiKey] and associate
  /// with [userId] (Firebase UID).
  Future<void> initialize({
    required String apiKey,
    required String userId,
  }) async {
    try {
      await _provider.initialize(apiKey);
      await _provider.identify(userId);
    } catch (e) {
      throw PurchaseException(
        'Failed to initialize purchases.',
        originalError: e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Query
  // ---------------------------------------------------------------------------

  /// Fetch the latest subscription status from RevenueCat.
  Future<SubscriptionModel> getSubscriptionStatus() async {
    try {
      final info = await _provider.getCustomerInfo();
      return _mapCustomerInfo(info);
    } catch (e) {
      throw PurchaseException(
        'Failed to fetch subscription status.',
        originalError: e,
      );
    }
  }

  /// Stream of subscription state changes (renewal, expiry, etc.).
  Stream<SubscriptionModel> get subscriptionChanges {
    return _provider.customerInfoStream.map(_mapCustomerInfo);
  }

  /// Convenience: whether the user currently has pro access.
  Future<bool> isProUser() async {
    final sub = await getSubscriptionStatus();
    return sub.hasProAccess;
  }

  /// Convenience: whether a free trial is active.
  Future<bool> isTrialActive() async {
    final sub = await getSubscriptionStatus();
    return sub.isTrialActive;
  }

  /// Days remaining in the trial (0 if not in trial).
  Future<int> trialDaysRemaining() async {
    final sub = await getSubscriptionStatus();
    return sub.daysLeftInTrial;
  }

  // ---------------------------------------------------------------------------
  // Purchase
  // ---------------------------------------------------------------------------

  /// Start the purchase flow for the given [plan].
  Future<void> purchasePackage(PlanType plan) async {
    final packageId = _planPackageIds[plan];
    if (packageId == null) {
      throw PurchaseException('Unknown plan type: ${plan.name}');
    }
    try {
      await _provider.purchase(packageId);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled') || msg.contains('userCancelled')) {
        throw const PurchaseCancelledException();
      }
      if (msg.contains('already') || msg.contains('ALREADY_PURCHASED')) {
        throw const PurchaseAlreadyActiveException();
      }
      throw PurchaseException('Purchase failed.', originalError: e);
    }
  }

  /// Restore purchases (e.g. reinstall, new device).
  Future<void> restorePurchases() async {
    try {
      await _provider.restorePurchases();
    } catch (e) {
      throw PurchaseException(
        'Failed to restore purchases.',
        originalError: e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Mapping
  // ---------------------------------------------------------------------------

  /// Convert raw RevenueCat customer info to [SubscriptionModel].
  SubscriptionModel _mapCustomerInfo(Map<String, dynamic> info) {
    final entitlements =
        info['entitlements'] as Map<String, dynamic>? ?? {};
    final proEntitlement =
        entitlements['pro'] as Map<String, dynamic>?;

    if (proEntitlement == null || proEntitlement['isActive'] != true) {
      return const SubscriptionModel(
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.expired,
      );
    }

    final isTrial =
        proEntitlement['periodType'] == 'TRIAL' ||
        proEntitlement['periodType'] == 'trial';

    final expiresAtStr = proEntitlement['expirationDate'] as String?;
    final expiresAt =
        expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;

    return SubscriptionModel(
      tier: SubscriptionTier.pro,
      status: isTrial ? SubscriptionStatus.trial : SubscriptionStatus.active,
      expiresAt: expiresAt,
      trialEndsAt: isTrial ? expiresAt : null,
    );
  }
}
