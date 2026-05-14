import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/streak_model.dart';

void main() {
  final _fixedDate = DateTime(2025, 6, 1, 12, 0, 0);

  StreakModel _createStreak({
    int currentStreak = 7,
    int longestStreak = 14,
    DateTime? lastSummaryDate,
    int freezesRemaining = 2,
    int freezesUsedThisWeek = 1,
    List<DateTime>? activeDays,
  }) {
    return StreakModel(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastSummaryDate: lastSummaryDate ?? _fixedDate,
      freezesRemaining: freezesRemaining,
      freezesUsedThisWeek: freezesUsedThisWeek,
      activeDays: activeDays ?? [_fixedDate],
    );
  }

  group('StreakModel.fromJson', () {
    test('creates model with all fields present', () {
      final activeDays = [
        DateTime(2025, 5, 30),
        DateTime(2025, 5, 31),
        DateTime(2025, 6, 1),
      ];

      final json = {
        'currentStreak': 7,
        'longestStreak': 14,
        'lastSummaryDate': _fixedDate.toIso8601String(),
        'freezesRemaining': 2,
        'freezesUsedThisWeek': 1,
        'activeDays':
            activeDays.map((d) => d.toIso8601String()).toList(),
      };

      final model = StreakModel.fromJson(json);

      expect(model.currentStreak, 7);
      expect(model.longestStreak, 14);
      expect(model.lastSummaryDate, _fixedDate);
      expect(model.freezesRemaining, 2);
      expect(model.freezesUsedThisWeek, 1);
      expect(model.activeDays, hasLength(3));
      expect(model.activeDays[0], DateTime(2025, 5, 30));
    });

    test('applies defaults for missing/null fields', () {
      final model = StreakModel.fromJson(<String, dynamic>{});

      expect(model.currentStreak, 0);
      expect(model.longestStreak, 0);
      expect(model.lastSummaryDate, isNull);
      expect(model.freezesRemaining, 0);
      expect(model.freezesUsedThisWeek, 0);
      expect(model.activeDays, isEmpty);
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final activeDays = [
        DateTime(2025, 5, 30),
        DateTime(2025, 5, 31),
      ];
      final original = _createStreak(activeDays: activeDays);
      final restored = StreakModel.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('StreakModel.toJson', () {
    test('serializes all fields correctly', () {
      final model = _createStreak();
      final json = model.toJson();

      expect(json['currentStreak'], 7);
      expect(json['longestStreak'], 14);
      expect(json['lastSummaryDate'], _fixedDate.toIso8601String());
      expect(json['freezesRemaining'], 2);
      expect(json['freezesUsedThisWeek'], 1);
      expect(json['activeDays'], isA<List>());
    });

    test('serializes null lastSummaryDate as null', () {
      final model = const StreakModel();
      final json = model.toJson();

      expect(json['lastSummaryDate'], isNull);
    });
  });

  group('StreakModel.copyWith', () {
    test('copies with no changes returns equal model', () {
      final model = _createStreak();
      expect(model.copyWith(), equals(model));
    });

    test('copies with changed currentStreak', () {
      final model = _createStreak(currentStreak: 7);
      final copy = model.copyWith(currentStreak: 8);

      expect(copy.currentStreak, 8);
      expect(copy.longestStreak, model.longestStreak);
    });

    test('copies with changed freezesRemaining', () {
      final model = _createStreak(freezesRemaining: 2);
      final copy = model.copyWith(freezesRemaining: 1);

      expect(copy.freezesRemaining, 1);
    });

    test('copies with changed activeDays', () {
      final model = _createStreak();
      final newDays = [DateTime(2025, 6, 2), DateTime(2025, 6, 3)];
      final copy = model.copyWith(activeDays: newDays);

      expect(copy.activeDays, hasLength(2));
      expect(copy.activeDays[0], DateTime(2025, 6, 2));
    });
  });

  group('StreakModel Equatable', () {
    test('two models with same values are equal', () {
      final a = _createStreak();
      final b = _createStreak();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two models with different currentStreak are not equal', () {
      final a = _createStreak(currentStreak: 5);
      final b = _createStreak(currentStreak: 10);

      expect(a, isNot(equals(b)));
    });
  });

  group('StreakModel.isAtRisk', () {
    test('is true when last summary was yesterday', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1, 10, 0);
      final model = _createStreak(lastSummaryDate: yesterday);

      expect(model.isAtRisk, isTrue);
    });

    test('is false when last summary was today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 8, 0);
      final model = _createStreak(lastSummaryDate: today);

      expect(model.isAtRisk, isFalse);
    });

    test('is false when last summary was 2 days ago', () {
      final now = DateTime.now();
      final twoDaysAgo = DateTime(now.year, now.month, now.day - 2, 10, 0);
      final model = _createStreak(lastSummaryDate: twoDaysAgo);

      expect(model.isAtRisk, isFalse);
    });

    test('is false when lastSummaryDate is null', () {
      final model = const StreakModel(lastSummaryDate: null);

      expect(model.isAtRisk, isFalse);
    });
  });

  group('StreakModel activeDays serialization', () {
    test('empty activeDays serializes to empty list', () {
      final model = _createStreak(activeDays: []);
      final json = model.toJson();

      expect(json['activeDays'], isEmpty);
    });

    test('activeDays preserves DateTime precision through roundtrip', () {
      final days = [
        DateTime(2025, 5, 28, 9, 30),
        DateTime(2025, 5, 29, 14, 0),
        DateTime(2025, 5, 30, 18, 45),
      ];
      final model = _createStreak(activeDays: days);
      final restored = StreakModel.fromJson(model.toJson());

      expect(restored.activeDays, hasLength(3));
      expect(restored.activeDays[0], days[0]);
      expect(restored.activeDays[1], days[1]);
      expect(restored.activeDays[2], days[2]);
    });
  });
}
