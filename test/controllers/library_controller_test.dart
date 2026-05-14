import 'dart:async';

import 'package:ai_master/controllers/library_controller.dart';
import 'package:ai_master/controllers/providers.dart';
import 'package:ai_master/controllers/states.dart';
import 'package:ai_master/models/summary_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_services.dart';
import '../helpers/test_factories.dart';

void main() {
  late MockLibraryStorage mockStorage;
  late ProviderContainer container;

  /// Seed the storage with a standard set of summaries.
  void seedSummaries({int count = 5}) {
    final summaries = TestFactories.createSummaryList(count: count);
    for (final s in summaries) {
      mockStorage.seed([s.toJson()]);
    }
  }

  setUp(() {
    mockStorage = MockLibraryStorage();
    seedSummaries();

    container = ProviderContainer(overrides: [
      libraryStorageAdapter.overrideWithValue(mockStorage),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  LibraryController notifier() {
    return container.read(libraryControllerProvider.notifier);
  }

  LibraryState? currentState() {
    return container.read(libraryControllerProvider).valueOrNull;
  }

  group('LibraryController', () {
    test('build() loads all summaries', () async {
      final state = await container.read(libraryControllerProvider.future);

      expect(state.summaries, hasLength(5));
      expect(state.searchQuery, isEmpty);
      expect(state.activeFilter, isNull);
      expect(state.isLoading, isFalse);
    });

    test('build() returns empty state on storage error', () async {
      mockStorage.shouldThrow = true;

      container.dispose();
      container = ProviderContainer(overrides: [
        libraryStorageAdapter.overrideWithValue(mockStorage),
      ]);

      final state = await container.read(libraryControllerProvider.future);

      expect(state.summaries, isEmpty);
    });

    test('search filters results by query', () async {
      await container.read(libraryControllerProvider.future);

      // Seed a summary with a distinctive title for searching.
      await mockStorage.put(TestFactories.createSummary(
        id: 'searchable',
        title: 'Unique Quantum Computing Article',
        paragraphSummary: 'Quantum computing is revolutionary.',
      ).toJson());

      await notifier().search('Quantum');

      final state = currentState()!;
      expect(state.summaries, isNotEmpty);
      expect(state.searchQuery, equals('Quantum'));
      // All results should match the query.
      for (final s in state.summaries) {
        final matches = s.title.toLowerCase().contains('quantum') ||
            s.paragraphSummary.toLowerCase().contains('quantum');
        expect(matches, isTrue);
      }
    });

    test('search with empty string returns all summaries', () async {
      await container.read(libraryControllerProvider.future);

      await notifier().search('');

      final state = currentState()!;
      // Empty search returns all summaries (via getAllSummaries).
      expect(state.summaries, hasLength(5));
    });

    test('filterByType filters by source type', () async {
      await container.read(libraryControllerProvider.future);

      await notifier().filterByType(SummarySourceType.url);

      final state = currentState()!;
      expect(state.activeFilter, equals(SummarySourceType.url));
      // All results should have the URL source type.
      for (final s in state.summaries) {
        expect(s.sourceType, equals(SummarySourceType.url));
      }
    });

    test('filterByType with null clears filter', () async {
      await container.read(libraryControllerProvider.future);

      // First apply a filter.
      await notifier().filterByType(SummarySourceType.pdf);
      expect(currentState()!.activeFilter, equals(SummarySourceType.pdf));

      // Then clear it.
      await notifier().filterByType(null);

      final state = currentState()!;
      expect(state.activeFilter, isNull);
      expect(state.summaries, hasLength(5)); // All summaries returned.
    });

    test('deleteSummary removes item from list (optimistic)', () async {
      await container.read(libraryControllerProvider.future);
      final initialCount = currentState()!.summaries.length;
      final idToDelete = currentState()!.summaries.first.id;

      await notifier().deleteSummary(idToDelete);

      final state = currentState()!;
      expect(state.summaries.length, equals(initialCount - 1));
      expect(state.summaries.where((s) => s.id == idToDelete), isEmpty);
    });

    test('deleteSummary - error re-fetches (rollback)', () async {
      await container.read(libraryControllerProvider.future);

      // Delete should fail, triggering a re-fetch via loadSummaries.
      mockStorage.shouldThrow = true;

      // The delete will fail, then loadSummaries will also fail (still throwing).
      // But the controller catches errors gracefully.
      await notifier().deleteSummary('test-summary-0');

      // State should still be valid (not crashed).
      final asyncState = container.read(libraryControllerProvider);
      expect(asyncState.hasValue, isTrue);
    });

    test('toggleFavorite flips the isFavorite flag', () async {
      await container.read(libraryControllerProvider.future);
      final targetId = currentState()!.summaries.first.id;
      final wasFavorite = currentState()!.summaries.first.isFavorite;

      await notifier().toggleFavorite(targetId);

      final state = currentState()!;
      final updated = state.summaries.firstWhere((s) => s.id == targetId);
      expect(updated.isFavorite, equals(!wasFavorite));
    });

    test('toggleFavorite - error re-fetches', () async {
      await container.read(libraryControllerProvider.future);

      // Make storage throw so toggleFavorite fails.
      mockStorage.shouldThrow = true;

      await notifier().toggleFavorite('test-summary-0');

      // Should not crash; state remains valid.
      final asyncState = container.read(libraryControllerProvider);
      expect(asyncState.hasValue, isTrue);
    });

    test('loadSummaries reloads from storage', () async {
      await container.read(libraryControllerProvider.future);

      // Add new item to storage directly.
      await mockStorage.put(TestFactories.createSummary(
        id: 'extra-summary',
        title: 'Extra Summary',
      ).toJson());

      await notifier().loadSummaries();

      final state = currentState()!;
      expect(state.summaries.length, equals(6)); // 5 original + 1 new.
    });

    test('loadSummaries sets isLoading true during fetch', () async {
      await container.read(libraryControllerProvider.future);

      final loadingStates = <bool>[];
      container.listen(
        libraryControllerProvider,
        (prev, next) {
          final val = next.valueOrNull;
          if (val != null) {
            loadingStates.add(val.isLoading);
          }
        },
        fireImmediately: false,
      );

      await notifier().loadSummaries();

      // Should have set isLoading to true at some point.
      expect(loadingStates, contains(true));
    });

    test('search preserves activeFilter in state', () async {
      await container.read(libraryControllerProvider.future);

      // Set a filter first.
      await notifier().filterByType(SummarySourceType.url);

      // Then search.
      await notifier().search('Test');

      final state = currentState()!;
      expect(state.activeFilter, equals(SummarySourceType.url));
      expect(state.searchQuery, equals('Test'));
    });

    test('multiple deleteSummary calls work correctly', () async {
      await container.read(libraryControllerProvider.future);
      final ids = currentState()!.summaries.map((s) => s.id).toList();

      await notifier().deleteSummary(ids[0]);
      await notifier().deleteSummary(ids[1]);

      final state = currentState()!;
      expect(state.summaries.length, equals(3));
      expect(state.summaries.where((s) => s.id == ids[0]), isEmpty);
      expect(state.summaries.where((s) => s.id == ids[1]), isEmpty);
    });
  });
}
