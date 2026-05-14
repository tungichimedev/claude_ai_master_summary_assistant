import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/streak_service.dart';
import 'package:ai_master/models/streak_model.dart';
import 'package:ai_master/utils/exceptions.dart';

// =============================================================================
// Mock StreakStorage (in-memory)
// =============================================================================

class MockStreakStorage implements StreakStorage {
  Map<String, dynamic>? _data;
  bool shouldThrow = false;

  @override
  Future<Map<String, dynamic>?> get() async {
    if (shouldThrow) throw Exception('Storage read error');
    return _data;
  }

  @override
  Future<void> put(Map<String, dynamic> data) async {
    if (shouldThrow) throw Exception('Storage write error');
    _data = Map<String, dynamic>.from(data);
    // Deep-copy the activeDays list.
    if (data['activeDays'] != null) {
      _data!['activeDays'] = List<dynamic>.from(data['activeDays'] as List);
    }
  }

  /// Seed the storage with a specific StreakModel.
  Future<void> seed(StreakModel model) async {
    _data = model.toJson();
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
  // getStreak
  // ---------------------------------------------------------------------------

  group('getStreak', () {
    test('returns default StreakModel when storage is empty', () async {
      final streak = await service.getStreak();
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.lastSummaryDate, isNull);
      expect(streak.freezesRemaining, 0);
    });

    test('returns stored streak data', () async {
      final now = DateTime.now();
      await storage.seed(StreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastSummaryDate: now,
        freezesRemaining: 2,
      ));

      final streak = await service.getStreak();
      expect(streak.currentStreak, 5);
      expect(streak.longestStreak, 10);
      expect(streak.freezesRemaining, 2);
    });

    test('throws StorageException on storage failure', () async {
      storage.shouldThrow = true;
      expect(
        () => service.getStreak(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // recordSummaryToday
  // ---------------------------------------------------------------------------

  group('recordSummaryToday', () {
    test('starts streak at 1 on first-ever summary', () async {
      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
      expect(result.lastSummaryDate, isNotNull);
    });

    test('increments streak on consecutive day', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await storage.seed(StreakModel(
        currentStreak: 3,
        longestStreak: 5,
        lastSummaryDate: yesterday,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 4);
    });

    test('does NOT increment on same day (already recorded)', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);
      await storage.seed(StreakModel(
        currentStreak: 3,
        longestStreak: 5,
        lastSummaryDate: today,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 3); // unchanged
    });

    test('resets streak after missed day (no freeze)', () async {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      await storage.seed(StreakModel(
        currentStreak: 7,
        longestStreak: 10,
        lastSummaryDate: twoDaysAgo,
        freezesRemaining: 0,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 1); // reset
      expect(result.longestStreak, 10); // preserved
    });

    test('resets streak after missing multiple days', () async {
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
      await storage.seed(StreakModel(
        currentStreak: 20,
        longestStreak: 20,
        lastSummaryDate: fiveDaysAgo,
        freezesRemaining: 1,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 1); // reset (too many days missed)
    });

    test('uses streak freeze to prevent reset on missed one day', () async {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      await storage.seed(StreakModel(
        currentStreak: 7,
        longestStreak: 10,
        lastSummaryDate: twoDaysAgo,
        freezesRemaining: 2,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 8); // streak preserved + incremented
      expect(result.freezesRemaining, 1); // one freeze used
    });

    test('updates longest streak when current surpasses it', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await storage.seed(StreakModel(
        currentStreak: 10,
        longestStreak: 10,
        lastSummaryDate: yesterday,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 11);
      expect(result.longestStreak, 11);
    });

    test('does not update longest streak when current is below it', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await storage.seed(StreakModel(
        currentStreak: 3,
        longestStreak: 50,
        lastSummaryDate: yesterday,
      ));

      final result = await service.recordSummaryToday();
      expect(result.currentStreak, 4);
      expect(result.longestStreak, 50); // unchanged
    });

    test('adds today to activeDays', () async {
      final result = await service.recordSummaryToday();
      expect(result.activeDays, isNotEmpty);
    });

    test('persists updated streak to storage', () async {
      await service.recordSummaryToday();
      final stored = await storage.get();
      expect(stored, isNotNull);
      expect(stored!['currentStreak'], 1);
    });

    test('throws StorageException on storage failure', () async {
      storage.shouldThrow = true;
      expect(
        () => service.recordSummaryToday(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // useStreakFreeze
  // ---------------------------------------------------------------------------

  group('useStreakFreeze', () {
    test('decrements freezesRemaining', () async {
      await storage.seed(const StreakModel(
        currentStreak: 5,
        freezesRemaining: 2,
        freezesUsedThisWeek: 0,
      ));

      await service.useStreakFreeze();
      final streak = await service.getStreak();
      expect(streak.freezesRemaining, 1);
      expect(streak.freezesUsedThisWeek, 1);
    });

    test('throws DailyLimitReachedException when no freezes left', () async {
      await storage.seed(const StreakModel(
        currentStreak: 5,
        freezesRemaining: 0,
      ));

      expect(
        () => service.useStreakFreeze(),
        throwsA(isA<DailyLimitReachedException>()),
      );
    });

    test('persists changes to storage', () async {
      await storage.seed(const StreakModel(
        currentStreak: 3,
        freezesRemaining: 1,
        freezesUsedThisWeek: 0,
      ));

      await service.useStreakFreeze();
      final stored = await storage.get();
      expect(stored!['freezesRemaining'], 0);
      expect(stored['freezesUsedThisWeek'], 1);
    });
  });

  // ---------------------------------------------------------------------------
  // shouldShowMilestone
  // ---------------------------------------------------------------------------

  group('shouldShowMilestone', () {
    test('returns true for milestone at 7 days', () {
      expect(service.shouldShowMilestone(7), true);
    });

    test('returns true for milestone at 14 days', () {
      expect(service.shouldShowMilestone(14), true);
    });

    test('returns true for milestone at 30 days', () {
      expect(service.shouldShowMilestone(30), true);
    });

    test('returns true for milestone at 50 days', () {
      expect(service.shouldShowMilestone(50), true);
    });

    test('returns true for milestone at 100 days', () {
      expect(service.shouldShowMilestone(100), true);
    });

    test('returns true for milestone at 200 days', () {
      expect(service.shouldShowMilestone(200), true);
    });

    test('returns true for milestone at 365 days', () {
      expect(service.shouldShowMilestone(365), true);
    });

    test('returns false for non-milestone days', () {
      expect(service.shouldShowMilestone(1), false);
      expect(service.shouldShowMilestone(5), false);
      expect(service.shouldShowMilestone(8), false);
      expect(service.shouldShowMilestone(15), false);
      expect(service.shouldShowMilestone(29), false);
      expect(service.shouldShowMilestone(99), false);
    });

    test('returns false for 0', () {
      expect(service.shouldShowMilestone(0), false);
    });

    test('returns false for negative values', () {
      expect(service.shouldShowMilestone(-1), false);
    });
  });
}
