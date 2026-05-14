import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/usage_model.dart';

void main() {
  final _fixedDate = DateTime(2025, 6, 1, 12, 0, 0);

  UsageModel _createUsage({
    int summariesUsed = 2,
    int tokensUsed = 3000,
    int expertQueriesUsed = 1,
    DateTime? lastResetDate,
    int dailyLimit = 5,
    int tokenLimit = 10000,
  }) {
    return UsageModel(
      summariesUsed: summariesUsed,
      tokensUsed: tokensUsed,
      expertQueriesUsed: expertQueriesUsed,
      lastResetDate: lastResetDate ?? _fixedDate,
      dailyLimit: dailyLimit,
      tokenLimit: tokenLimit,
    );
  }

  group('UsageModel.fromJson', () {
    test('creates model with all fields present', () {
      final json = {
        'summariesUsed': 3,
        'tokensUsed': 5000,
        'expertQueriesUsed': 2,
        'lastResetDate': _fixedDate.toIso8601String(),
        'dailyLimit': 5,
        'tokenLimit': 10000,
      };

      final model = UsageModel.fromJson(json);

      expect(model.summariesUsed, 3);
      expect(model.tokensUsed, 5000);
      expect(model.expertQueriesUsed, 2);
      expect(model.lastResetDate, _fixedDate);
      expect(model.dailyLimit, 5);
      expect(model.tokenLimit, 10000);
    });

    test('applies defaults for missing/null fields', () {
      final model = UsageModel.fromJson(<String, dynamic>{});

      expect(model.summariesUsed, 0);
      expect(model.tokensUsed, 0);
      expect(model.expertQueriesUsed, 0);
      expect(model.dailyLimit, 3);
      expect(model.tokenLimit, 10000);
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final original = _createUsage();
      final restored = UsageModel.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('UsageModel.toJson', () {
    test('serializes all fields correctly', () {
      final model = _createUsage();
      final json = model.toJson();

      expect(json['summariesUsed'], 2);
      expect(json['tokensUsed'], 3000);
      expect(json['expertQueriesUsed'], 1);
      expect(json['lastResetDate'], _fixedDate.toIso8601String());
      expect(json['dailyLimit'], 5);
      expect(json['tokenLimit'], 10000);
    });
  });

  group('UsageModel.copyWith', () {
    test('copies with no changes returns equal model', () {
      final model = _createUsage();
      expect(model.copyWith(), equals(model));
    });

    test('copies with changed summariesUsed', () {
      final model = _createUsage(summariesUsed: 2);
      final copy = model.copyWith(summariesUsed: 4);

      expect(copy.summariesUsed, 4);
      expect(copy.tokensUsed, model.tokensUsed);
    });

    test('copies with changed dailyLimit', () {
      final model = _createUsage(dailyLimit: 5);
      final copy = model.copyWith(dailyLimit: 10);

      expect(copy.dailyLimit, 10);
    });
  });

  group('UsageModel Equatable', () {
    test('two models with same values are equal', () {
      final a = _createUsage();
      final b = _createUsage();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two models with different summariesUsed are not equal', () {
      final a = _createUsage(summariesUsed: 1);
      final b = _createUsage(summariesUsed: 2);

      expect(a, isNot(equals(b)));
    });
  });

  group('UsageModel computed getters', () {
    test('hasReachedDailyLimit is true when summariesUsed >= dailyLimit', () {
      final atLimit = _createUsage(summariesUsed: 5, dailyLimit: 5);
      expect(atLimit.hasReachedDailyLimit, isTrue);

      final overLimit = _createUsage(summariesUsed: 6, dailyLimit: 5);
      expect(overLimit.hasReachedDailyLimit, isTrue);
    });

    test('hasReachedDailyLimit is false when summariesUsed < dailyLimit', () {
      final underLimit = _createUsage(summariesUsed: 3, dailyLimit: 5);
      expect(underLimit.hasReachedDailyLimit, isFalse);
    });

    test('hasReachedTokenLimit is true when tokensUsed >= tokenLimit', () {
      final atLimit = _createUsage(tokensUsed: 10000, tokenLimit: 10000);
      expect(atLimit.hasReachedTokenLimit, isTrue);

      final overLimit = _createUsage(tokensUsed: 15000, tokenLimit: 10000);
      expect(overLimit.hasReachedTokenLimit, isTrue);
    });

    test('hasReachedTokenLimit is false when tokensUsed < tokenLimit', () {
      final underLimit = _createUsage(tokensUsed: 5000, tokenLimit: 10000);
      expect(underLimit.hasReachedTokenLimit, isFalse);
    });

    test('summariesRemaining returns correct count', () {
      final model = _createUsage(summariesUsed: 2, dailyLimit: 5);
      expect(model.summariesRemaining, 3);
    });

    test('summariesRemaining is clamped to 0 when over limit', () {
      final model = _createUsage(summariesUsed: 7, dailyLimit: 5);
      expect(model.summariesRemaining, 0);
    });

    test('summariesRemaining equals dailyLimit when none used', () {
      final model = _createUsage(summariesUsed: 0, dailyLimit: 5);
      expect(model.summariesRemaining, 5);
    });
  });
}
