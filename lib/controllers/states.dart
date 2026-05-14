import 'package:equatable/equatable.dart';

import '../models/expert_model.dart';
import '../models/streak_model.dart';
import '../models/summary_model.dart';
import '../utils/summary_format.dart';

// =============================================================================
// SummaryState — used by SummarizerController
// =============================================================================

/// Sealed hierarchy representing every possible state of a summarisation
/// request.
sealed class SummaryState extends Equatable {
  const SummaryState();
}

/// No summarisation in progress.
class SummaryIdle extends SummaryState {
  const SummaryIdle();
  @override
  List<Object?> get props => [];
}

/// Summarisation has been submitted and is waiting for the server.
class SummaryLoading extends SummaryState {
  /// Optional progress indicator (0.0 – 1.0) for multi-step operations
  /// like PDF upload.
  final double? progress;
  const SummaryLoading({this.progress});
  @override
  List<Object?> get props => [progress];
}

/// Streaming response in progress — partial content available.
class SummaryStreaming extends SummaryState {
  final String partialContent;
  const SummaryStreaming({required this.partialContent});
  @override
  List<Object?> get props => [partialContent];
}

/// Summarisation completed successfully.
class SummarySuccess extends SummaryState {
  final SummaryModel summary;
  final SummaryFormat activeFormat;
  const SummarySuccess({
    required this.summary,
    this.activeFormat = SummaryFormat.bullets,
  });
  @override
  List<Object?> get props => [summary, activeFormat];
}

/// Summarisation failed.
class SummaryError extends SummaryState {
  final String message;
  const SummaryError({required this.message});
  @override
  List<Object?> get props => [message];
}

// =============================================================================
// HomeState — used by HomeController
// =============================================================================

class HomeState extends Equatable {
  /// URL detected on the clipboard, or null.
  final String? clipboardUrl;

  /// Text detected on the clipboard, or null.
  final String? clipboardText;

  /// Most recently saved summaries (limit 5).
  final List<SummaryModel> recentSummaries;

  /// A curated "Summary of the Day" card, or null if unavailable.
  final SummaryModel? summaryOfTheDay;

  /// Number of summaries the user can still create today.
  final int usageRemaining;

  /// Current streak state.
  final StreakModel streak;

  const HomeState({
    this.clipboardUrl,
    this.clipboardText,
    this.recentSummaries = const [],
    this.summaryOfTheDay,
    this.usageRemaining = 0,
    this.streak = const StreakModel(),
  });

  HomeState copyWith({
    String? clipboardUrl,
    String? clipboardText,
    List<SummaryModel>? recentSummaries,
    SummaryModel? summaryOfTheDay,
    int? usageRemaining,
    StreakModel? streak,
  }) {
    return HomeState(
      clipboardUrl: clipboardUrl ?? this.clipboardUrl,
      clipboardText: clipboardText ?? this.clipboardText,
      recentSummaries: recentSummaries ?? this.recentSummaries,
      summaryOfTheDay: summaryOfTheDay ?? this.summaryOfTheDay,
      usageRemaining: usageRemaining ?? this.usageRemaining,
      streak: streak ?? this.streak,
    );
  }

  @override
  List<Object?> get props => [
        clipboardUrl,
        clipboardText,
        recentSummaries,
        summaryOfTheDay,
        usageRemaining,
        streak,
      ];
}

// =============================================================================
// LibraryState — used by LibraryController
// =============================================================================

class LibraryState extends Equatable {
  final List<SummaryModel> summaries;
  final String searchQuery;
  final SummarySourceType? activeFilter;
  final bool isLoading;

  const LibraryState({
    this.summaries = const [],
    this.searchQuery = '',
    this.activeFilter,
    this.isLoading = false,
  });

  LibraryState copyWith({
    List<SummaryModel>? summaries,
    String? searchQuery,
    SummarySourceType? activeFilter,
    bool? isLoading,
    bool clearFilter = false,
  }) {
    return LibraryState(
      summaries: summaries ?? this.summaries,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [summaries, searchQuery, activeFilter, isLoading];
}

// =============================================================================
// ExpertChatState — used by ExpertController
// =============================================================================

class ExpertChatState extends Equatable {
  final ExpertType expert;
  final List<ExpertMessage> messages;
  final bool isStreaming;

  const ExpertChatState({
    this.expert = ExpertType.writingAssistant,
    this.messages = const [],
    this.isStreaming = false,
  });

  ExpertChatState copyWith({
    ExpertType? expert,
    List<ExpertMessage>? messages,
    bool? isStreaming,
  }) {
    return ExpertChatState(
      expert: expert ?? this.expert,
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [expert, messages, isStreaming];
}

// =============================================================================
// PaywallType — used by SubscriptionController
// =============================================================================

/// The kind of paywall to show based on context.
enum PaywallType {
  /// Dismissible, shown after first successful summary.
  soft,

  /// Non-dismissible, shown when free limit is reached.
  hard,

  /// Contextual bottom sheet, shown when tapping a locked feature.
  micro,
}
