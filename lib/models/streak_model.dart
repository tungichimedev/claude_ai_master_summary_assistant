import 'package:equatable/equatable.dart';

/// Tracks the user's daily summary streak and freeze inventory.
///
/// [activeDays] stores the last 14 days on which the user created at least
/// one summary — used for the streak calendar UI widget.
class StreakModel extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastSummaryDate;
  final int freezesRemaining;
  final int freezesUsedThisWeek;
  final List<DateTime> activeDays;

  const StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSummaryDate,
    this.freezesRemaining = 0,
    this.freezesUsedThisWeek = 0,
    this.activeDays = const [],
  });

  /// Whether the streak is at risk (last summary was yesterday, none today).
  bool get isAtRisk {
    if (lastSummaryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastSummaryDate!.year,
      lastSummaryDate!.month,
      lastSummaryDate!.day,
    );
    return today.difference(lastDay).inDays == 1;
  }

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastSummaryDate: json['lastSummaryDate'] != null
          ? DateTime.parse(json['lastSummaryDate'] as String)
          : null,
      freezesRemaining: json['freezesRemaining'] as int? ?? 0,
      freezesUsedThisWeek: json['freezesUsedThisWeek'] as int? ?? 0,
      activeDays: (json['activeDays'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastSummaryDate': lastSummaryDate?.toIso8601String(),
      'freezesRemaining': freezesRemaining,
      'freezesUsedThisWeek': freezesUsedThisWeek,
      'activeDays':
          activeDays.map((d) => d.toIso8601String()).toList(),
    };
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSummaryDate,
    int? freezesRemaining,
    int? freezesUsedThisWeek,
    List<DateTime>? activeDays,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSummaryDate: lastSummaryDate ?? this.lastSummaryDate,
      freezesRemaining: freezesRemaining ?? this.freezesRemaining,
      freezesUsedThisWeek: freezesUsedThisWeek ?? this.freezesUsedThisWeek,
      activeDays: activeDays ?? this.activeDays,
    );
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        lastSummaryDate,
        freezesRemaining,
        freezesUsedThisWeek,
        activeDays,
      ];
}
