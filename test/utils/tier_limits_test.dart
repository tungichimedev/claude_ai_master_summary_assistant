import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/subscription_model.dart';
import 'package:ai_master/utils/tier_limits.dart';

void main() {
  group('SubscriptionTier.free limits', () {
    const tier = SubscriptionTier.free;

    test('libraryLimit is 20', () {
      expect(tier.libraryLimit, 20);
    });

    test('dailySummaryLimit is 3', () {
      expect(tier.dailySummaryLimit, 3);
    });

    test('dailyTokenLimit is 5000', () {
      expect(tier.dailyTokenLimit, 5000);
    });

    test('canUploadPdf is false', () {
      expect(tier.canUploadPdf, isFalse);
    });

    test('showsAds is true', () {
      expect(tier.showsAds, isTrue);
    });

    test('canShareCards is false', () {
      expect(tier.canShareCards, isFalse);
    });
  });

  group('SubscriptionTier.pro limits', () {
    const tier = SubscriptionTier.pro;

    test('libraryLimit is -1 (unlimited)', () {
      expect(tier.libraryLimit, -1);
    });

    test('dailySummaryLimit is -1 (unlimited)', () {
      expect(tier.dailySummaryLimit, -1);
    });

    test('dailyTokenLimit is 200000', () {
      expect(tier.dailyTokenLimit, 200000);
    });

    test('canUploadPdf is true', () {
      expect(tier.canUploadPdf, isTrue);
    });

    test('showsAds is false', () {
      expect(tier.showsAds, isFalse);
    });

    test('canShareCards is true', () {
      expect(tier.canShareCards, isTrue);
    });
  });

  group('Tier differentiation', () {
    test('pro has higher token limit than free', () {
      expect(SubscriptionTier.pro.dailyTokenLimit,
          greaterThan(SubscriptionTier.free.dailyTokenLimit));
    });

    test('free has finite limits while pro is unlimited for summaries', () {
      expect(SubscriptionTier.free.dailySummaryLimit, greaterThan(0));
      expect(SubscriptionTier.pro.dailySummaryLimit, equals(-1));
    });

    test('free has finite library while pro is unlimited', () {
      expect(SubscriptionTier.free.libraryLimit, greaterThan(0));
      expect(SubscriptionTier.pro.libraryLimit, equals(-1));
    });
  });
}
