import 'dart:async';

import 'package:ai_master/controllers/home_controller.dart';
import 'package:ai_master/controllers/providers.dart';
import 'package:ai_master/controllers/states.dart';
import 'package:ai_master/models/streak_model.dart';
import 'package:ai_master/models/summary_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_services.dart';
import '../helpers/test_factories.dart';

void main() {
  late MockLibraryStorage mockLibraryStorage;
  late MockClipboardProvider mockClipboardProvider;
  late MockUsageCache mockUsageCache;
  late MockStreakStorage mockStreakStorage;
  late ProviderContainer container;

  setUp(() {
    mockLibraryStorage = MockLibraryStorage();
    mockClipboardProvider = MockClipboardProvider();
    mockUsageCache = MockUsageCache();
    mockStreakStorage = MockStreakStorage();

    // Seed data for library.
    final summaries = TestFactories.createSummaryList(count: 7);
    for (final s in summaries) {
      mockLibraryStorage.seed([s.toJson()]);
    }

    // Seed usage cache.
    mockUsageCache.seed(TestFactories.createUsageJson());

    // Seed streak storage.
    mockStreakStorage.seed(TestFactories.createStreakJson());

    container = ProviderContainer(overrides: [
      libraryStorageAdapter.overrideWithValue(mockLibraryStorage),
      clipboardProviderAdapter.overrideWithValue(mockClipboardProvider),
      usageCacheAdapter.overrideWithValue(mockUsageCache),
      streakStorageAdapter.overrideWithValue(mockStreakStorage),
      // Override dioProvider since UsageService needs it but we use cached data.
      apiBaseUrlProvider.overrideWithValue('http://localhost:9999'),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  HomeController notifier() {
    return container.read(homeControllerProvider.notifier);
  }

  group('HomeController', () {
    test('build() loads all data in parallel and returns HomeState', () async {
      mockClipboardProvider.textToReturn = 'https://example.com/article';

      final state = await container.read(homeControllerProvider.future);

      expect(state, isA<HomeState>());
      expect(state.clipboardUrl, equals('https://example.com/article'));
      // Recent summaries should be limited to 5.
      expect(state.recentSummaries.length, lessThanOrEqualTo(5));
    });

    test('build() returns minimal HomeState on error', () async {
      // Make everything fail.
      mockLibraryStorage.shouldThrow = true;
      mockClipboardProvider.shouldThrow = true;

      // Re-create container to trigger fresh build.
      container.dispose();
      container = ProviderContainer(overrides: [
        libraryStorageAdapter.overrideWithValue(mockLibraryStorage),
        clipboardProviderAdapter.overrideWithValue(mockClipboardProvider),
        usageCacheAdapter.overrideWithValue(mockUsageCache),
        streakStorageAdapter.overrideWithValue(mockStreakStorage),
        apiBaseUrlProvider.overrideWithValue('http://localhost:9999'),
      ]);

      final state = await container.read(homeControllerProvider.future);

      // Should return default HomeState, not throw.
      expect(state, isA<HomeState>());
      expect(state.recentSummaries, isEmpty);
    });

    test('checkClipboard - found URL updates state', () async {
      mockClipboardProvider.textToReturn = null;
      await container.read(homeControllerProvider.future);

      // Now change clipboard and check.
      mockClipboardProvider.textToReturn = 'https://news.example.com/story';
      await notifier().checkClipboard();

      final state = container.read(homeControllerProvider).value!;
      expect(state.clipboardUrl, equals('https://news.example.com/story'));
    });

    test('checkClipboard - no URL returns null clipboardUrl', () async {
      mockClipboardProvider.textToReturn = 'just short text';
      await container.read(homeControllerProvider.future);

      await notifier().checkClipboard();

      final state = container.read(homeControllerProvider).value!;
      expect(state.clipboardUrl, isNull);
    });

    test('checkClipboard - long text sets clipboardText', () async {
      // 20+ words of non-URL text.
      mockClipboardProvider.textToReturn =
          'This is a long piece of text that contains more than twenty words '
          'and should be detected as clipboard text rather than a URL by the '
          'clipboard service logic for summarization purposes.';
      await container.read(homeControllerProvider.future);

      await notifier().checkClipboard();

      final state = container.read(homeControllerProvider).value!;
      expect(state.clipboardUrl, isNull);
      expect(state.clipboardText, isNotNull);
    });

    test('checkClipboard - clipboard error is silently ignored', () async {
      await container.read(homeControllerProvider.future);

      mockClipboardProvider.shouldThrow = true;
      // Should not throw.
      await notifier().checkClipboard();

      // State should still be valid.
      final asyncState = container.read(homeControllerProvider);
      expect(asyncState.hasValue, isTrue);
    });

    test('loadRecentSummaries returns sorted list limited to 5', () async {
      await container.read(homeControllerProvider.future);

      await notifier().loadRecentSummaries();

      final state = container.read(homeControllerProvider).value!;
      expect(state.recentSummaries.length, lessThanOrEqualTo(5));
      // Verify sorted by date (newest first).
      if (state.recentSummaries.length > 1) {
        for (int i = 0; i < state.recentSummaries.length - 1; i++) {
          expect(
            state.recentSummaries[i].createdAt
                .isAfter(state.recentSummaries[i + 1].createdAt) ||
            state.recentSummaries[i].createdAt
                .isAtSameMomentAs(state.recentSummaries[i + 1].createdAt),
            isTrue,
          );
        }
      }
    });

    test('loadRecentSummaries - error preserves current state', () async {
      await container.read(homeControllerProvider.future);
      final stateBefore = container.read(homeControllerProvider).value;

      mockLibraryStorage.shouldThrow = true;
      await notifier().loadRecentSummaries();

      // State should not have become an error; previous value preserved.
      final stateAfter = container.read(homeControllerProvider);
      expect(stateAfter.hasValue, isTrue);
    });

    test('refresh reloads all data', () async {
      await container.read(homeControllerProvider.future);

      // Add a new summary to the storage.
      final newSummary = TestFactories.createSummary(
        id: 'new-summary',
        title: 'Fresh Summary',
      );
      await mockLibraryStorage.put(newSummary.toJson());

      await notifier().refresh();

      final state = container.read(homeControllerProvider).value!;
      // Should have the refreshed data.
      expect(state, isA<HomeState>());
    });

    test('build() with URL on clipboard sets clipboardUrl', () async {
      mockClipboardProvider.textToReturn = 'https://example.com/test';

      final state = await container.read(homeControllerProvider.future);

      expect(state.clipboardUrl, equals('https://example.com/test'));
      expect(state.clipboardText, isNull);
    });

    test('build() with empty clipboard sets both to null', () async {
      mockClipboardProvider.textToReturn = null;

      final state = await container.read(homeControllerProvider.future);

      expect(state.clipboardUrl, isNull);
      expect(state.clipboardText, isNull);
    });
  });
}
