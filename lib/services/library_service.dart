import 'dart:async';

import '../models/subscription_model.dart';
import '../models/summary_model.dart';
import '../utils/exceptions.dart';
import '../utils/tier_limits.dart';

/// Abstract local-storage interface so we can swap Isar for another DB later.
///
/// This is the contract — the concrete Isar implementation lives in a
/// separate file and is injected via the provider.
abstract class LibraryStorage {
  Future<void> put(Map<String, dynamic> json);
  Future<void> delete(String id);
  Future<void> update(String id, Map<String, dynamic> changes);
  Future<Map<String, dynamic>?> get(String id);
  Future<List<Map<String, dynamic>>> getAll();
  Future<List<Map<String, dynamic>>> search(String query);
  Future<List<Map<String, dynamic>>> filterByField(String field, String value);
  Future<int> count();
}

/// Service for managing the offline summary library.
///
/// Pure Dart — depends on [LibraryStorage] (abstraction over Isar).
class LibraryService {
  final LibraryStorage _storage;

  LibraryService({required LibraryStorage storage}) : _storage = storage;

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// Persist a summary to the local library.
  ///
  /// Throws [LibraryFullException] if the tier's limit is reached.
  Future<void> saveSummary(SummaryModel summary) async {
    try {
      await _storage.put(summary.toJson());
    } catch (e) {
      throw StorageException('Failed to save summary.', originalError: e);
    }
  }

  /// Remove a summary from the library by its [id].
  Future<void> deleteSummary(String id) async {
    try {
      await _storage.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete summary.', originalError: e);
    }
  }

  /// Toggle the favourite flag on a summary.
  Future<void> toggleFavorite(String id) async {
    try {
      final json = await _storage.get(id);
      if (json == null) return;
      final current = json['isFavorite'] as bool? ?? false;
      await _storage.update(id, {'isFavorite': !current});
    } catch (e) {
      throw StorageException('Failed to toggle favourite.', originalError: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Return every saved summary, newest first.
  Future<List<SummaryModel>> getAllSummaries() async {
    try {
      final rows = await _storage.getAll();
      final summaries = rows.map(SummaryModel.fromJson).toList();
      summaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return summaries;
    } catch (e) {
      throw StorageException('Failed to load summaries.', originalError: e);
    }
  }

  /// Full-text search across title and paragraph summary.
  Future<List<SummaryModel>> searchSummaries(String query) async {
    if (query.trim().isEmpty) return getAllSummaries();
    try {
      final rows = await _storage.search(query);
      return rows.map(SummaryModel.fromJson).toList();
    } catch (e) {
      throw StorageException('Search failed.', originalError: e);
    }
  }

  /// Filter summaries by their source type (text, url, pdf).
  Future<List<SummaryModel>> filterByType(SummarySourceType type) async {
    try {
      final rows = await _storage.filterByField('sourceType', type.name);
      final summaries = rows.map(SummaryModel.fromJson).toList();
      summaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return summaries;
    } catch (e) {
      throw StorageException('Filter failed.', originalError: e);
    }
  }

  /// Returns the total number of summaries stored locally.
  Future<int> getSummaryCount() async {
    try {
      return await _storage.count();
    } catch (e) {
      throw StorageException('Failed to count summaries.', originalError: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Limit check
  // ---------------------------------------------------------------------------

  /// Whether the library has reached the maximum items for [tier].
  ///
  /// Pro/Ultra tiers have unlimited storage (returns false).
  bool isLibraryFull(SubscriptionTier tier, int currentCount) {
    final limit = tier.libraryLimit;
    if (limit == -1) return false; // unlimited
    return currentCount >= limit;
  }
}
