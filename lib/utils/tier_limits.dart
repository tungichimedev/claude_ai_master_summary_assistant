import '../models/subscription_model.dart';

/// Extends [SubscriptionTier] with business-rule limits per tier.
///
/// These values mirror the PRD Section 6.2 tier feature table.
/// Centralised here so services and controllers reference a single source of
/// truth for limit calculations.
extension TierLimits on SubscriptionTier {
  /// Maximum number of offline library items for this tier.
  /// Returns -1 for unlimited.
  int get libraryLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 20;
      case SubscriptionTier.pro:
        return -1; // unlimited
    }
  }

  /// Maximum daily summaries for this tier.
  /// Returns -1 for unlimited.
  int get dailySummaryLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 3;
      case SubscriptionTier.pro:
        return -1; // unlimited
    }
  }

  /// Maximum daily token budget for this tier.
  int get dailyTokenLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 5000;
      case SubscriptionTier.pro:
        return 200000;
    }
  }

  /// Whether this tier has access to PDF uploads.
  bool get canUploadPdf => this != SubscriptionTier.free;

  /// Whether this tier shows ads.
  bool get showsAds => this == SubscriptionTier.free;

  /// Whether this tier can create shareable summary cards.
  bool get canShareCards => this == SubscriptionTier.pro;
}
