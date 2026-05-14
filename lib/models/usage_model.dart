import 'package:equatable/equatable.dart';

/// Tracks the user's resource consumption for the current billing period.
///
/// Limits are derived from the user's subscription tier. The counters
/// reset on [lastResetDate] (typically daily for summaries, monthly for tokens).
class UsageModel extends Equatable {
  final int summariesUsed;
  final int tokensUsed;
  final int expertQueriesUsed;
  final DateTime lastResetDate;
  final int dailyLimit;
  final int tokenLimit;

  const UsageModel({
    this.summariesUsed = 0,
    this.tokensUsed = 0,
    this.expertQueriesUsed = 0,
    required this.lastResetDate,
    required this.dailyLimit,
    required this.tokenLimit,
  });

  /// Whether the user has reached their daily summary limit.
  bool get hasReachedDailyLimit => summariesUsed >= dailyLimit;

  /// Whether the user has exhausted their token budget.
  bool get hasReachedTokenLimit => tokensUsed >= tokenLimit;

  /// Remaining summaries for the day.
  int get summariesRemaining =>
      (dailyLimit - summariesUsed).clamp(0, dailyLimit);

  factory UsageModel.fromJson(Map<String, dynamic> json) {
    return UsageModel(
      summariesUsed: json['summariesUsed'] as int? ?? 0,
      tokensUsed: json['tokensUsed'] as int? ?? 0,
      expertQueriesUsed: json['expertQueriesUsed'] as int? ?? 0,
      lastResetDate: json['lastResetDate'] != null
          ? DateTime.parse(json['lastResetDate'] as String)
          : DateTime.now(),
      dailyLimit: json['dailyLimit'] as int? ?? 3,
      tokenLimit: json['tokenLimit'] as int? ?? 10000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summariesUsed': summariesUsed,
      'tokensUsed': tokensUsed,
      'expertQueriesUsed': expertQueriesUsed,
      'lastResetDate': lastResetDate.toIso8601String(),
      'dailyLimit': dailyLimit,
      'tokenLimit': tokenLimit,
    };
  }

  UsageModel copyWith({
    int? summariesUsed,
    int? tokensUsed,
    int? expertQueriesUsed,
    DateTime? lastResetDate,
    int? dailyLimit,
    int? tokenLimit,
  }) {
    return UsageModel(
      summariesUsed: summariesUsed ?? this.summariesUsed,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      expertQueriesUsed: expertQueriesUsed ?? this.expertQueriesUsed,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      tokenLimit: tokenLimit ?? this.tokenLimit,
    );
  }

  @override
  List<Object?> get props => [
        summariesUsed,
        tokensUsed,
        expertQueriesUsed,
        lastResetDate,
        dailyLimit,
        tokenLimit,
      ];
}
