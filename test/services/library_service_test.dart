import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/library_service.dart';
import 'package:ai_master/models/summary_model.dart';
import 'package:ai_master/models/subscription_model.dart';
import 'package:ai_master/utils/exceptions.dart';

// =============================================================================
// Mock LibraryStorage (in-memory)
// =============================================================================

class MockLibraryStorage implements LibraryStorage {
  final Map<String, Map<String, dynamic>> _store = {};
  bool shouldThrow = false;

  @override
  Future<void> put(Map<String, dynamic> json) async {
    if (shouldThrow) throw Exception('Storage write error');
    final id = json['id'] as String;
    _store[id] = Map<String, dynamic>.from(json);
  }

  @override
  Future<void> delete(String id) async {
    if (shouldThrow) throw Exception('Storage delete error');
    _store.remove(id);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> changes) async {
    if (shouldThrow) throw Exception('Storage update error');
    if (_store.containsKey(id)) {
      _store[id]!.addAll(changes);
    }
  }

  @override
  Future<Map<String, dynamic>?> get(String id) async {
    if (shouldThrow) throw Exception('Storage read error');
    return _store[id];
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    if (shouldThrow) throw Exception('Storage getAll error');
    return _store.values.toList();
  }

  @override
  Future<List<Map<String, dynamic>>> search(String query) async {
    if (shouldThrow) throw Exception('Storage search error');
    final lowerQuery = query.toLowerCase();
    return _store.values.where((json) {
      final title = (json['title'] as String? ?? '').toLowerCase();
      final content = (json['paragraphSummary'] as String? ?? '').toLowerCase();
      return title.contains(lowerQuery) || content.contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> filterByField(
      String field, String value) async {
    if (shouldThrow) throw Exception('Storage filter error');
    return _store.values.where((json) => json[field] == value).toList();
  }

  @override
  Future<int> count() async {
    if (shouldThrow) throw Exception('Storage count error');
    return _store.length;
  }
}

// =============================================================================
// Test helpers
// =============================================================================

SummaryModel _makeSummary({
  required String id,
  String title = 'Test Summary',
  SummarySourceType sourceType = SummarySourceType.text,
  bool isFavorite = false,
  DateTime? createdAt,
}) {
  return SummaryModel(
    id: id,
    title: title,
    sourceType: sourceType,
    originalContent: 'Some original content for $title',
    bulletPoints: const ['Point 1', 'Point 2'],
    paragraphSummary: 'A paragraph summary about $title',
    keyTakeaways: const ['Takeaway 1'],
    actionItems: const ['Action 1'],
    wordCount: 100,
    createdAt: createdAt ?? DateTime(2026, 1, 15),
    isFavorite: isFavorite,
  );
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  late MockLibraryStorage storage;
  late LibraryService service;

  setUp(() {
    storage = MockLibraryStorage();
    service = LibraryService(storage: storage);
  });

  // ---------------------------------------------------------------------------
  // saveSummary
  // ---------------------------------------------------------------------------

  group('saveSummary', () {
    test('stores summary correctly', () async {
      final summary = _makeSummary(id: 's1');
      await service.saveSummary(summary);

      final stored = await storage.get('s1');
      expect(stored, isNotNull);
      expect(stored!['id'], 's1');
      expect(stored['title'], 'Test Summary');
    });

    test('overwrites existing summary with same id', () async {
      await service.saveSummary(_makeSummary(id: 's1', title: 'First'));
      await service.saveSummary(_makeSummary(id: 's1', title: 'Second'));

      final stored = await storage.get('s1');
      expect(stored!['title'], 'Second');
    });

    test('throws StorageException on storage failure', () async {
      storage.shouldThrow = true;
      expect(
        () => service.saveSummary(_makeSummary(id: 's1')),
        throwsA(isA<StorageException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // deleteSummary
  // ---------------------------------------------------------------------------

  group('deleteSummary', () {
    test('removes item from storage', () async {
      await service.saveSummary(_makeSummary(id: 's1'));
      await service.deleteSummary('s1');

      final stored = await storage.get('s1');
      expect(stored, isNull);
    });

    test('does not throw when deleting non-existent id', () async {
      // Should not throw — just a no-op.
      await service.deleteSummary('non-existent');
    });

    test('throws StorageException on storage failure', () async {
      storage.shouldThrow = true;
      expect(
        () => service.deleteSummary('s1'),
        throwsA(isA<StorageException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // toggleFavorite
  // ---------------------------------------------------------------------------

  group('toggleFavorite', () {
    test('flips isFavorite from false to true', () async {
      await service.saveSummary(_makeSummary(id: 's1', isFavorite: false));
      await service.toggleFavorite('s1');

      final stored = await storage.get('s1');
      expect(stored!['isFavorite'], true);
    });

    test('flips isFavorite from true to false', () async {
      await service.saveSummary(_makeSummary(id: 's1', isFavorite: true));
      await service.toggleFavorite('s1');

      final stored = await storage.get('s1');
      expect(stored!['isFavorite'], false);
    });

    test('does nothing for non-existent id', () async {
      // Should not throw — the service returns early if null.
      await service.toggleFavorite('non-existent');
    });

    test('throws StorageException on storage failure', () async {
      storage.shouldThrow = true;
      expect(
        () => service.toggleFavorite('s1'),
        throwsA(isA<StorageException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getAllSummaries
  // ---------------------------------------------------------------------------

  group('getAllSummaries', () {
    test('returns all items sorted newest first', () async {
      await service.saveSummary(
          _makeSummary(id: 's1', createdAt: DateTime(2026, 1, 1)));
      await service.saveSummary(
          _makeSummary(id: 's2', createdAt: DateTime(2026, 3, 1)));
      await service.saveSummary(
          _makeSummary(id: 's3', createdAt: DateTime(2026, 2, 1)));

      final results = await service.getAllSummaries();
      expect(results.length, 3);
      expect(results[0].id, 's2'); // March (newest)
      expect(results[1].id, 's3'); // February
      expect(results[2].id, 's1'); // January (oldest)
    });

    test('returns empty list when no summaries stored', () async {
      final results = await service.getAllSummaries();
      expect(results, isEmpty);
    });

    test('throws StorageException on storage failure', () async {
      storage.shouldThrow = true;
      expect(
        () => service.getAllSummaries(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // searchSummaries
  // ---------------------------------------------------------------------------

  group('searchSummaries', () {
    setUp(() async {
      await service.saveSummary(
          _makeSummary(id: 's1', title: 'Flutter Architecture Guide'));
      await service.saveSummary(
          _makeSummary(id: 's2', title: 'Dart Concurrency Patterns'));
      await service.saveSummary(
          _makeSummary(id: 's3', title: 'React vs Flutter Comparison'));
    });

    test('finds summaries by title', () async {
      final results = await service.searchSummaries('Flutter');
      expect(results.length, 2);
    });

    test('finds summaries by content', () async {
      // paragraphSummary contains the title as part of template.
      final results = await service.searchSummaries('paragraph');
      expect(results.length, 3); // all have "paragraph" in paragraphSummary
    });

    test('returns empty list when no match', () async {
      final results = await service.searchSummaries('nonexistent-xyz');
      expect(results, isEmpty);
    });

    test('returns all summaries for empty query', () async {
      final results = await service.searchSummaries('');
      expect(results.length, 3);
    });

    test('returns all summaries for whitespace-only query', () async {
      final results = await service.searchSummaries('   ');
      expect(results.length, 3);
    });

    test('search is case-insensitive', () async {
      final results = await service.searchSummaries('flutter');
      expect(results.length, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // filterByType
  // ---------------------------------------------------------------------------

  group('filterByType', () {
    setUp(() async {
      await service.saveSummary(
          _makeSummary(id: 's1', sourceType: SummarySourceType.text));
      await service.saveSummary(
          _makeSummary(id: 's2', sourceType: SummarySourceType.url));
      await service.saveSummary(
          _makeSummary(id: 's3', sourceType: SummarySourceType.pdf));
      await service.saveSummary(
          _makeSummary(id: 's4', sourceType: SummarySourceType.text));
    });

    test('returns only text summaries', () async {
      final results = await service.filterByType(SummarySourceType.text);
      expect(results.length, 2);
      expect(results.every((s) => s.sourceType == SummarySourceType.text), true);
    });

    test('returns only url summaries', () async {
      final results = await service.filterByType(SummarySourceType.url);
      expect(results.length, 1);
      expect(results.first.sourceType, SummarySourceType.url);
    });

    test('returns only pdf summaries', () async {
      final results = await service.filterByType(SummarySourceType.pdf);
      expect(results.length, 1);
      expect(results.first.sourceType, SummarySourceType.pdf);
    });

    test('returns empty list when no match', () async {
      // Remove all pdf summaries.
      await service.deleteSummary('s3');
      final results = await service.filterByType(SummarySourceType.pdf);
      expect(results, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getSummaryCount
  // ---------------------------------------------------------------------------

  group('getSummaryCount', () {
    test('returns 0 for empty library', () async {
      expect(await service.getSummaryCount(), 0);
    });

    test('returns accurate count', () async {
      await service.saveSummary(_makeSummary(id: 's1'));
      await service.saveSummary(_makeSummary(id: 's2'));
      await service.saveSummary(_makeSummary(id: 's3'));

      expect(await service.getSummaryCount(), 3);
    });

    test('count decreases after deletion', () async {
      await service.saveSummary(_makeSummary(id: 's1'));
      await service.saveSummary(_makeSummary(id: 's2'));
      await service.deleteSummary('s1');

      expect(await service.getSummaryCount(), 1);
    });

    test('throws StorageException on storage failure', () async {
      storage.shouldThrow = true;
      expect(
        () => service.getSummaryCount(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // isLibraryFull
  // ---------------------------------------------------------------------------

  group('isLibraryFull', () {
    test('returns true when free tier at limit (20)', () {
      expect(service.isLibraryFull(SubscriptionTier.free, 20), true);
    });

    test('returns true when free tier above limit', () {
      expect(service.isLibraryFull(SubscriptionTier.free, 25), true);
    });

    test('returns false when free tier under limit', () {
      expect(service.isLibraryFull(SubscriptionTier.free, 19), false);
    });

    test('returns false when free tier has 0 items', () {
      expect(service.isLibraryFull(SubscriptionTier.free, 0), false);
    });

    test('returns false for pro tier regardless of count', () {
      expect(service.isLibraryFull(SubscriptionTier.pro, 0), false);
      expect(service.isLibraryFull(SubscriptionTier.pro, 100), false);
      expect(service.isLibraryFull(SubscriptionTier.pro, 10000), false);
    });
  });
}
