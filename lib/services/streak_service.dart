import 'dart:async';

import '../models/streak_model.dart';
import '../utils/exceptions.dart';

/// Abstract local-storage interface for streak data.
///
/// Can be backed by SharedPreferences, Isar, or any key-value store.
abstract class StreakStorage {
  Future<Map<String, dynamic>?> get();
  Future<void> put(Map<String, dynamic> data);
}

/// Milestone thresholds that trigger a celebration in the UI.
const streakMilestones = [7, 14, 30, 50, 100, 200, 365];

/// Service for managing the daily summary streak.
///
/// Pure Dart — depends on [StreakStorage] abstraction.
/// All date calculations are timezone-aware using local time.
class StreakService {
  final StreakStorage _storage;

  StreakService({required StreakStorage storage}) : _storage = storage;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Load the current streak state from local storage.
  Future<StreakModel> getStreak() async {
    try {
      final data = await _storage.get();
      if (data == null) return const StreakModel();
      return StreakModel.fromJson(data);
    } catch (e) {
      throw StorageException('Failed to load streak.', originalError: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Record activity
  // ---------------------------------------------------------------------------

  /// Record that the user created a summary today.
  ///
  /// - If already active today, returns existing streak unchanged.
  /// - If last active was yesterday, increments the streak.
  /// - If last active was >1 day ago (and no freeze available), resets to 1.
  Future<StreakModel> recordSummaryToday() async {
    try {
      final current = await getStreak();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Already recorded today — no-op.
      if (current.lastSummaryDate != null) {
        final lastDay = DateTime(
          current.lastSummaryDate!.year,
          current.lastSummaryDate!.month,
          current.lastSummaryDate!.day,
        );
        if (lastDay == today) return current;
      }

      int newStreak;
      bool freezeUsed = false;
      int freezes = current.freezesRemaining;

      if (current.lastSummaryDate == null) {
        // First ever summary.
        newStreak = 1;
      } else {
        final lastDay = DateTime(
          current.lastSummaryDate!.year,
          current.lastSummaryDate!.month,
          current.lastSummaryDate!.day,
        );
        final daysDiff = today.difference(lastDay).inDays;

        if (daysDiff == 1) {
          // Consecutive day — increment.
          newStreak = current.currentStreak + 1;
        } else if (daysDiff == 2 && freezes > 0) {
          // Missed one day but freeze available — preserve streak.
          newStreak = current.currentStreak + 1;
          freezes -= 1;
          freezeUsed = true;
        } else {
          // Streak broken — reset.
          newStreak = 1;
        }
      }

      final longestStreak =
          newStreak > current.longestStreak ? newStreak : current.longestStreak;

      // Update active days (keep last 14 days).
      final activeDays = List<DateTime>.from(current.activeDays)..add(now);
      final cutoff = today.subtract(const Duration(days: 14));
      activeDays.removeWhere((d) => d.isBefore(cutoff));

      final updated = StreakModel(
        currentStreak: newStreak,
        longestStreak: longestStreak,
        lastSummaryDate: now,
        freezesRemaining: freezes,
        freezesUsedThisWeek:
            freezeUsed ? current.freezesUsedThisWeek + 1 : current.freezesUsedThisWeek,
        activeDays: activeDays,
      );

      await _storage.put(updated.toJson());
      return updated;
    } catch (e) {
      if (e is AppException) rethrow;
      throw StorageException('Failed to record streak.', originalError: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Streak freeze
  // ---------------------------------------------------------------------------

  /// Manually use a streak freeze for the current day.
  Future<void> useStreakFreeze() async {
    try {
      final current = await getStreak();
      if (current.freezesRemaining <= 0) {
        throw const DailyLimitReachedException(
          limit: 0,
          message: 'No streak freezes remaining.',
        );
      }
      final updated = current.copyWith(
        freezesRemaining: current.freezesRemaining - 1,
        freezesUsedThisWeek: current.freezesUsedThisWeek + 1,
      );
      await _storage.put(updated.toJson());
    } catch (e) {
      if (e is AppException) rethrow;
      throw StorageException('Failed to use streak freeze.', originalError: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Milestones
  // ---------------------------------------------------------------------------

  /// Whether a milestone celebration should be shown for [streak].
  bool shouldShowMilestone(int streak) {
    return streakMilestones.contains(streak);
  }
}
