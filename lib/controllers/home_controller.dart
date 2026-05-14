import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription_model.dart';

import 'providers.dart';
import 'states.dart';

/// Controller for the home screen ("Summarize" tab).
///
/// Aggregates data from multiple services: clipboard detection, recent
/// summaries, usage tracking, and streaks.
class HomeController extends AutoDisposeAsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    // Load all data sources in parallel on initial build.
    try {
      final clipboard = ref.read(clipboardServiceProvider);
      final library = ref.read(libraryServiceProvider);
      final usage = ref.read(usageServiceProvider);
      final streak = ref.read(streakServiceProvider);

      final results = await Future.wait([
        clipboard.getClipboardUrl(),
        clipboard.getClipboardText(),
        library.getAllSummaries(),
        usage.remainingSummaries(SubscriptionTier.free), // Default; upgraded at runtime.
        streak.getStreak(),
      ]);

      final clipboardUrl = results[0] as String?;
      final clipboardText = results[1] as String?;
      final allSummaries =
          results[2] as List<dynamic>;
      final remaining = results[3] as int;
      final streakModel =
          results[4] as dynamic;

      // Take the 5 most recent summaries.
      final recent = allSummaries.take(5).toList();

      return HomeState(
        clipboardUrl: clipboardUrl,
        clipboardText: clipboardText,
        recentSummaries: recent.cast(),
        usageRemaining: remaining,
        streak: streakModel,
      );
    } catch (e) {
      // Return a minimal state so the home screen still renders.
      return const HomeState();
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Re-check the clipboard for URLs or long text.
  Future<void> checkClipboard() async {
    try {
      final clipboard = ref.read(clipboardServiceProvider);
      final url = await clipboard.getClipboardUrl();
      final text = await clipboard.getClipboardText();

      final current = state.valueOrNull ?? const HomeState();
      state = AsyncData(current.copyWith(
        clipboardUrl: url,
        clipboardText: text,
      ));
    } catch (_) {
      // Clipboard read can fail on some platforms; silently ignore.
    }
  }

  /// Reload recent summaries from the library.
  Future<void> loadRecentSummaries() async {
    try {
      final library = ref.read(libraryServiceProvider);
      final all = await library.getAllSummaries();
      final recent = all.take(5).toList();

      final current = state.valueOrNull ?? const HomeState();
      state = AsyncData(current.copyWith(recentSummaries: recent));
    } catch (e) {
      // Non-fatal — leave current state.
    }
  }

  /// Load the "Summary of the Day" (curated trending content).
  ///
  /// In MVP this is a no-op / placeholder. In v2.0 this will fetch from a
  /// remote feed endpoint.
  Future<void> loadSummaryOfTheDay() async {
    // TODO: Implement remote "trending article" feed in v2.0.
    // For now, the summaryOfTheDay field remains null.
  }

  /// Refresh all home screen data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}
