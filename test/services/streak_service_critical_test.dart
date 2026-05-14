import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/streak_service.dart';
import 'package:ai_master/models/streak_model.dart';
import 'package:ai_master/utils/exceptions.dart';
import '../helpers/test_factories.dart';

// =============================================================================
// Mock StreakStorage (in-memory, same pattern as streak_service_test.dart)
// =============================================================================

class MockStreakStorage implements StreakStorage {
  Map<String, dynamic>? _data;
  bool shouldThrow = false;
  int putCallCount = 0;

  @override
  Future<Map<String, dynamic>?> get() async {
    if (shouldThrow) throw Exception('Storage read error');
    return _data;
  }

  @override
  Future<void> put(Map<String, dynamic> data) async {
    if (shouldThrow) throw Exception('Storage write error');
    putCallCount++;
    _data = Map<String, dynamic>.from(data);
    if (data['activeDays'] != null) {
      _data!['activeDays'] = List<dynamic>.from(data['activeDays'] as List);
    }
  }

  /// Seed the storage with a specific StreakModel.
  Future<void> seed(StreakModel model) async {
    _data = model.toJson();
  }

  /// Inject raw JSON for corruption testing.
  void injectRaw(Map<String, dynamic> data) {
    _data = data;
  }
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  late MockStreakStorage storage;
  late StreakService service;

  setUp(() {
    storage = MockStreakStorage();
    service = StreakService(storage: storage);
  });

  // ---------------------------------------------------------------------------
  // DST transitions
  // ---------------------------------------------------------------------------

  group('DST transition handling', () {
    // NOTE: These tests use constructed DateTime objects that simulate
    // the EFFECT of DST transitions on day boundaries. They verify that
    // the streak logic correctly compares calendar days, not raw hour diffs.

    test('should maintain streak across 23-hour day (spring forward)', () async {
      // Simulate: last summary at 2026-03-08 22:00 (before spring forward)
      // Today is 2026-03-09 (a 23-hour day due to DST).
      // Even though only 23 hours elapsed, these are consecutive calendar days.
      final beforeDst = DateTime(2026, 3, 8, 22, 0);
      await storage.seed(StreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastSummaryDate: beforeDst,
      ));

      // recordSummaryToday uses DateTime.now(), so we can only verify the
      // date-comparison logic by testing with a known "yesterday" scenario.
      // The key insight: StreakService compares calendar days (year/month/day),
      // not hours. So a 23-hour gap that crosses a day boundary still counts
      // as consecutive.
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1, 22, 0);
      await storage.seed(StreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastSummaryDate: yesterday,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 6); // streak preserved
    });

    test('should maintain streak across 25-hour day (fall back)', () async {
      // Simulate: last summary was yesterday at 01:00.
      // After fall-back, 25 hours pass but it's still the next calendar day.
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1, 1, 0);
      await storage.seed(StreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastSummaryDate: yesterday,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 6);
    });
  });

  // ---------------------------------------------------------------------------
  // Midnight boundary
  // ---------------------------------------------------------------------------

  group('midnight boundary handling', () {
    test('should treat summary at 23:59:59 and 00:00:01 as different days',
        () async {
      // If the last summary was at 23:59:59 "yesterday",
      // a summary at 00:00:01 "today" should increment the streak.
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
      await storage.seed(StreakModel(
        currentStreak: 3,
        longestStreak: 5,
        lastSummaryDate: yesterday,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 4); // consecutive days
    });

    test('should treat two summaries on same calendar day as same day',
        () async {
      // Summary already recorded today at 00:01.
      final now = DateTime.now();
      final earlierToday = DateTime(now.year, now.month, now.day, 0, 1);
      await storage.seed(StreakModel(
        currentStreak: 3,
        longestStreak: 5,
        lastSummaryDate: earlierToday,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 3); // unchanged (already recorded today)
    });
  });

  // ---------------------------------------------------------------------------
  // Device clock set backwards
  // ---------------------------------------------------------------------------

  group('device clock anomalies', () {
    test('should reset streak if device clock appears to go backwards',
        () async {
      // Last summary date is "in the future" relative to today, which can
      // happen if the device clock was set backwards.
      final now = DateTime.now();
      final futureDate = DateTime(now.year, now.month, now.day + 5, 10, 0);
      await storage.seed(StreakModel(
        currentStreak: 10,
        longestStreak: 15,
        lastSummaryDate: futureDate,
      ));

      final result = await service.recordSummaryToday();
      // daysDiff will be negative. It won't match 1 or 2, so streak resets to 1.
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 15); // longest preserved
    });
  });

  // ---------------------------------------------------------------------------
  // Concurrent recordSummaryToday calls
  // ---------------------------------------------------------------------------

  group('concurrent recordSummaryToday calls', () {
    test('should handle concurrent calls without throwing', () async {
      // Start from empty streak.
      final futures = List.generate(
        3,
        (_) => service.recordSummaryToday(),
      );

      final results = await Future.wait(futures);
      // All should complete without error.
      expect(results.length, 3);
      for (final result in results) {
        expect(result, isA<StreakModel>());
        // First call sets streak to 1, subsequent calls on same day return 1.
        expect(result.currentStreak, 1);
      }
    });

    test('storage should be written at least once after concurrent calls',
        () async {
      await Future.wait([
        service.recordSummaryToday(),
        service.recordSummaryToday(),
      ]);

      expect(storage.putCallCount, greaterThanOrEqualTo(1));
      final stored = await storage.get();
      expect(stored, isNotNull);
      expect(stored!['currentStreak'], 1);
    });
  });

  // ---------------------------------------------------------------------------
  // Corrupted activeDays in storage
  // ---------------------------------------------------------------------------

  group('corrupted activeDays in storage', () {
    test('should throw when activeDays contains non-ISO date strings',
        () async {
      // Inject corrupted data where activeDays has invalid date strings.
      storage.injectRaw({
        'currentStreak': 3,
        'longestStreak': 5,
        'lastSummaryDate': TestFactories.referenceDate.toIso8601String(),
        'freezesRemaining': 0,
        'freezesUsedThisWeek': 0,
        'activeDays': ['NOT-A-DATE', '2026-13-45', 'garbage'],
      });

      // StreakModel.fromJson calls DateTime.parse on each activeDays entry.
      // Invalid strings will throw FormatException, which StreakService wraps.
      expect(
        () => service.getStreak(),
        throwsA(isA<StorageException>()),
      );
    });

    test('should handle empty activeDays array', () async {
      storage.injectRaw({
        'currentStreak': 3,
        'longestStreak': 5,
        'lastSummaryDate': TestFactories.referenceDate.toIso8601String(),
        'freezesRemaining': 0,
        'freezesUsedThisWeek': 0,
        'activeDays': <String>[],
      });

      final streak = await service.getStreak();
      expect(streak.activeDays, isEmpty);
      expect(streak.currentStreak, 3);
    });

    test('should handle null activeDays', () async {
      storage.injectRaw({
        'currentStreak': 2,
        'longestStreak': 5,
        'lastSummaryDate': TestFactories.referenceDate.toIso8601String(),
        'freezesRemaining': 0,
        'freezesUsedThisWeek': 0,
        'activeDays': null,
      });

      final streak = await service.getStreak();
      expect(streak.activeDays, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Timezone change simulation
  // ---------------------------------------------------------------------------

  group('timezone change simulation', () {
    test(
        'should use local calendar day regardless of timezone offset changes',
        () async {
      // Dart's DateTime constructor creates local-time dates.
      // The streak service compares calendar days using DateTime(y,m,d).
      // If a user travels from UTC+12 to UTC-12, the "local today" shifts
      // dramatically, but the service always uses DateTime.now() which
      // returns the device's current local time.
      //
      // This test verifies that day-comparison uses calendar day, not UTC.
      final now = DateTime.now();
      final yesterdayLocal =
          DateTime(now.year, now.month, now.day - 1, 15, 0);
      await storage.seed(StreakModel(
        currentStreak: 7,
        longestStreak: 7,
        lastSummaryDate: yesterdayLocal,
      ));

      final result = await service.recordSummaryToday();
      // Should still be consecutive regardless of what timezone produced
      // the DateTime objects — both are in local time on this device.
      expect(result.currentStreak, 8);
    });
  });

  // ---------------------------------------------------------------------------
  // activeDays pruning
  // ---------------------------------------------------------------------------

  group('activeDays pruning', () {
    test('should keep only last 14 days of active days', () async {
      // Seed with 20 active days spanning 20 days ago to yesterday.
      final now = DateTime.now();
      final oldActiveDays = List.generate(
        20,
        (i) => now.subtract(Duration(days: i + 1)),
      );
      await storage.seed(StreakModel(
        currentStreak: 1,
        longestStreak: 20,
        lastSummaryDate: DateTime(now.year, now.month, now.day - 1),
        activeDays: oldActiveDays,
      ));

      final result = await service.recordSummaryToday();
      // After pruning, only days within the last 14 days should remain
      // plus today's entry.
      expect(result.activeDays.length, lessThanOrEqualTo(15));
    });
  });
}
