import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/summary_model.dart';

import 'providers.dart';
import 'states.dart';

/// Controller for the "Library" tab — manages the offline summary collection.
class LibraryController extends AutoDisposeAsyncNotifier<LibraryState> {
  @override
  Future<LibraryState> build() async {
    try {
      final library = ref.read(libraryServiceProvider);
      final summaries = await library.getAllSummaries();
      return LibraryState(summaries: summaries);
    } catch (e) {
      return const LibraryState();
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Reload all summaries from storage.
  Future<void> loadSummaries() async {
    _setLoading(true);
    try {
      final library = ref.read(libraryServiceProvider);
      final summaries = await library.getAllSummaries();
      state = AsyncData(LibraryState(summaries: summaries));
    } catch (e) {
      state = AsyncData(
        (state.valueOrNull ?? const LibraryState()).copyWith(isLoading: false),
      );
    }
  }

  /// Full-text search across title and content.
  Future<void> search(String query) async {
    _setLoading(true);
    try {
      final library = ref.read(libraryServiceProvider);
      final results = await library.searchSummaries(query);
      state = AsyncData(LibraryState(
        summaries: results,
        searchQuery: query,
        activeFilter: state.valueOrNull?.activeFilter,
      ));
    } catch (e) {
      state = AsyncData(
        (state.valueOrNull ?? const LibraryState()).copyWith(
          searchQuery: query,
          isLoading: false,
        ),
      );
    }
  }

  /// Filter summaries by source type, or clear the filter if [type] is null.
  Future<void> filterByType(SummarySourceType? type) async {
    _setLoading(true);
    try {
      final library = ref.read(libraryServiceProvider);
      final results = type != null
          ? await library.filterByType(type)
          : await library.getAllSummaries();
      state = AsyncData(LibraryState(
        summaries: results,
        searchQuery: state.valueOrNull?.searchQuery ?? '',
        activeFilter: type,
      ));
    } catch (e) {
      state = AsyncData(
        (state.valueOrNull ?? const LibraryState()).copyWith(
          isLoading: false,
          clearFilter: type == null,
        ),
      );
    }
  }

  /// Delete a summary by its [id] and refresh the list.
  Future<void> deleteSummary(String id) async {
    try {
      final library = ref.read(libraryServiceProvider);
      await library.deleteSummary(id);
      // Optimistic removal from local state.
      final current = state.valueOrNull ?? const LibraryState();
      final updated =
          current.summaries.where((s) => s.id != id).toList();
      state = AsyncData(current.copyWith(summaries: updated));
    } catch (e) {
      // Re-fetch to ensure consistency.
      await loadSummaries();
    }
  }

  /// Toggle favourite status on a summary.
  Future<void> toggleFavorite(String id) async {
    try {
      final library = ref.read(libraryServiceProvider);
      await library.toggleFavorite(id);
      // Optimistic toggle in local state.
      final current = state.valueOrNull ?? const LibraryState();
      final updated = current.summaries.map((s) {
        if (s.id == id) return s.copyWith(isFavorite: !s.isFavorite);
        return s;
      }).toList();
      state = AsyncData(current.copyWith(summaries: updated));
    } catch (e) {
      await loadSummaries();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setLoading(bool loading) {
    final current = state.valueOrNull ?? const LibraryState();
    state = AsyncData(current.copyWith(isLoading: loading));
  }
}
