import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/library_service.dart';
import 'package:ai_master/models/summary_model.dart';
import 'package:ai_master/models/subscription_model.dart';
import 'package:ai_master/utils/exceptions.dart';
import 'package:ai_master/utils/tier_limits.dart';
import '../helpers/test_factories.dart';

// =============================================================================
// Mock LibraryStorage (in-memory, same pattern as library_service_test.dart)
// =============================================================================

class MockLibraryStorage implements LibraryStorage {
  final Map<String, Map<String, dynamic>> _store = {};
  bool shouldThrow = false;
  int putCallCount = 0;

  /// Inject raw JSON directly (for corruption testing).
  void injectRaw(String id, Map<String, dynamic> data) {
    _store[id] = data;
  }

  @override
  Future<void> put(Map<String, dynamic> json) async {
    if (shouldThrow) throw Exception('Storage write error');
    putCallCount++;
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
      final content =
          (json['paragraphSummary'] as String? ?? '').toLowerCase();
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
  // Tier limit enforcement
  // ---------------------------------------------------------------------------

  group('isLibraryFull tier limit enforcement', () {
    test('should report full when free tier has exactly 20 items', () {
      expect(service.isLibraryFull(SubscriptionTier.free, 20), isTrue);
    });

    test('should report full when free tier exceeds 20 items', () {
      expect(service.isLibraryFull(SubscriptionTier.free, 50), isTrue);
    });

    test('should not report full when free tier has 19 items', () {
      expect(service.isLibraryFull(SubscriptionTier.free, 19), isFalse);
    });

    test('should allow unlimited for pro tier with 50+ items', () {
      expect(service.isLibraryFull(SubscriptionTier.pro, 50), isFalse);
      expect(service.isLibraryFull(SubscriptionTier.pro, 10000), isFalse);
    });

    test('free tier library limit matches TierLimits constant', () {
      expect(SubscriptionTier.free.libraryLimit, 20);
    });

    test('pro tier library limit is unlimited (-1)', () {
      expect(SubscriptionTier.pro.libraryLimit, -1);
    });
  });

  // ---------------------------------------------------------------------------
  // Corrupted storage data
  // ---------------------------------------------------------------------------

  group('corrupted storage data handling', () {
    test('should throw StorageException when storage contains non-parseable data',
        () async {
      // Inject data that will cause SummaryModel.fromJson to throw
      // (e.g., createdAt is not a valid ISO string).
      storage.injectRaw('corrupt-1', {
        'id': 'corrupt-1',
        'title': 'Good title',
        'sourceType': 'text',
        'originalContent': 'Content',
        'bulletPoints': <String>[],
        'paragraphSummary': 'Summary',
        'keyTakeaways': <String>[],
        'actionItems': <String>[],
        'wordCount': 10,
        'createdAt': 'NOT-A-DATE', // will cause DateTime.parse to throw
        'isFavorite': false,
        'tags': <String>[],
      });

      // getAllSummaries catches errors and wraps in StorageException
      expect(
        () => service.getAllSummaries(),
        throwsA(isA<StorageException>()),
      );
    });

    test('should throw StorageException when storage returns invalid JSON types',
        () async {
      // bulletPoints is a string instead of List — will throw on .map
      storage.injectRaw('corrupt-2', {
        'id': 'corrupt-2',
        'title': 'Bad types',
        'sourceType': 'text',
        'originalContent': 'Content',
        'bulletPoints': 'not-a-list',
        'paragraphSummary': 'Summary',
        'wordCount': 10,
        'createdAt': '2026-01-15T10:00:00.000Z',
      });

      expect(
        () => service.getAllSummaries(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Extremely long content
  // ---------------------------------------------------------------------------

  group('extremely long content handling', () {
    test('should save summary with 10000+ word content without error',
        () async {
      final longContent = List.generate(10001, (i) => 'word$i').join(' ');
      final summary = TestFactories.createSummary(
        id: 'long-1',
        originalContent: longContent,
      );

      await service.saveSummary(summary);
      final count = await service.getSummaryCount();
      expect(count, 1);
    });

    test('should retrieve summary with very long content', () async {
      final longContent = List.generate(10001, (i) => 'word$i').join(' ');
      final summary = TestFactories.createSummary(
        id: 'long-2',
        originalContent: longContent,
      );

      await service.saveSummary(summary);
      final results = await service.getAllSummaries();
      expect(results.length, 1);
      expect(results.first.originalContent.split(' ').length, 10001);
    });
  });

  // ---------------------------------------------------------------------------
  // Search with special characters
  // ---------------------------------------------------------------------------

  group('search with special characters', () {
    setUp(() async {
      await service.saveSummary(
        TestFactories.createSummary(id: 's1', title: 'Flutter Guide'),
      );
      await service.saveSummary(
        TestFactories.createSummary(id: 's2', title: 'Emoji Test 🎉🚀'),
      );
      await service.saveSummary(
        TestFactories.createSummary(
          id: 's3',
          title: 'Unicode niha\u0303o',
        ),
      );
    });

    test('should not crash when searching with emoji', () async {
      final results = await service.searchSummaries('🎉');
      // May or may not find results depending on search implementation,
      // but MUST NOT crash.
      expect(results, isA<List<SummaryModel>>());
    });

    test('should not crash when searching with unicode characters', () async {
      final results = await service.searchSummaries('niha\u0303o');
      expect(results, isA<List<SummaryModel>>());
    });

    test('should not crash when searching with SQL injection-like string',
        () async {
      final results = await service.searchSummaries("'; DROP TABLE summaries;--");
      expect(results, isA<List<SummaryModel>>());
      // Should return empty, not crash.
    });

    test('should not crash when searching with regex special characters',
        () async {
      final results = await service.searchSummaries(r'.*+?[](){}|\^$');
      expect(results, isA<List<SummaryModel>>());
    });
  });

  // ---------------------------------------------------------------------------
  // Concurrent toggleFavorite
  // ---------------------------------------------------------------------------

  group('concurrent toggleFavorite', () {
    test('should handle concurrent toggleFavorite on same item', () async {
      await service.saveSummary(
        TestFactories.createSummary(id: 'fav-1', isFavorite: false),
      );

      // Fire multiple toggles concurrently.
      await Future.wait([
        service.toggleFavorite('fav-1'),
        service.toggleFavorite('fav-1'),
      ]);

      // After two toggles, state may be true or false depending on
      // execution order. The key assertion is that it does NOT throw
      // and the item still exists.
      final stored = await storage.get('fav-1');
      expect(stored, isNotNull);
      expect(stored!['isFavorite'], isA<bool>());
    });
  });

  // ---------------------------------------------------------------------------
  // Downgrade scenario
  // ---------------------------------------------------------------------------

  group('downgrade from pro to free with items over limit', () {
    test(
        'isLibraryFull returns true after downgrade when user has 50+ items',
        () {
      // User had pro (unlimited), accumulated 50 items, then downgraded.
      expect(service.isLibraryFull(SubscriptionTier.free, 50), isTrue);
    });

    test('existing items remain readable after downgrade', () async {
      // Populate 25 items (over free limit).
      for (int i = 0; i < 25; i++) {
        await service.saveSummary(
          TestFactories.createSummary(
            id: 'item-$i',
            title: 'Summary $i',
            createdAt: TestFactories.referenceDate.subtract(Duration(hours: i)),
          ),
        );
      }

      // All 25 items should still be readable even if library is "full".
      final results = await service.getAllSummaries();
      expect(results.length, 25);
    });

    test('isLibraryFull correctly blocks new saves at free limit', () {
      // After downgrade: 25 items in library, free limit is 20.
      expect(service.isLibraryFull(SubscriptionTier.free, 25), isTrue);
      // Only callers (controllers) should check this before calling saveSummary.
    });
  });
}
