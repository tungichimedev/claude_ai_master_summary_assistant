import 'dart:async';
import 'dart:typed_data';

import 'package:ai_master/controllers/providers.dart';
import 'package:ai_master/controllers/states.dart';
import 'package:ai_master/controllers/summarizer_controller.dart';
import 'package:ai_master/models/summary_model.dart';
import 'package:ai_master/services/summarizer_service.dart';
import 'package:ai_master/utils/exceptions.dart';
import 'package:ai_master/utils/summary_format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_factories.dart';

// =============================================================================
// Mock SummarizerService
// =============================================================================

class MockSummarizerService implements SummarizerService {
  SummaryModel? summaryToReturn;
  Object? errorToThrow;
  List<String> streamChunks = [];
  bool streamShouldError = false;
  Object streamError = Exception('Stream error');
  final List<String> callLog = [];

  MockSummarizerService() {
    summaryToReturn = TestFactories.createSummary();
  }

  void reset() {
    summaryToReturn = TestFactories.createSummary();
    errorToThrow = null;
    streamChunks = [];
    streamShouldError = false;
    callLog.clear();
  }

  @override
  Future<SummaryModel> summarizeText(String text,
      {SummaryFormat format = SummaryFormat.bullets}) async {
    callLog.add('summarizeText');
    if (errorToThrow != null) throw errorToThrow!;
    return summaryToReturn!;
  }

  @override
  Stream<String> summarizeTextStream(String text) {
    callLog.add('summarizeTextStream');
    if (streamShouldError) {
      return Stream.error(streamError);
    }
    // Use an async* stream to ensure proper microtask scheduling.
    return _asyncStream(streamChunks);
  }

  @override
  Future<SummaryModel> summarizeUrl(String url,
      {SummaryFormat format = SummaryFormat.bullets}) async {
    callLog.add('summarizeUrl');
    if (errorToThrow != null) throw errorToThrow!;
    return summaryToReturn!;
  }

  @override
  Stream<String> summarizeUrlStream(String url) {
    callLog.add('summarizeUrlStream');
    if (streamShouldError) {
      return Stream.error(streamError);
    }
    return _asyncStream(streamChunks);
  }

  @override
  Future<SummaryModel> summarizePdf(Uint8List bytes, String fileName,
      {SummaryFormat format = SummaryFormat.bullets}) async {
    callLog.add('summarizePdf');
    if (errorToThrow != null) throw errorToThrow!;
    return summaryToReturn!;
  }

  @override
  List<String> toBullets(String content) => content.split('\n');

  @override
  String toParagraph(String content) => content.replaceAll('\n', ' ');

  @override
  List<String> toTakeaways(String content) => content.split('\n');

  @override
  List<String> toActionItems(String content) => content.split('\n');
}

Stream<String> _asyncStream(List<String> items) async* {
  for (final item in items) {
    yield item;
  }
}

// =============================================================================
// Helper
// =============================================================================

/// Pumps the event queue to allow microtasks and stream callbacks to complete.
Future<void> pumpEventQueue({int times = 50}) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  late MockSummarizerService mockService;
  late ProviderContainer container;
  late List<AsyncValue<SummaryState>> emittedStates;

  setUp(() {
    mockService = MockSummarizerService();
    container = ProviderContainer(overrides: [
      summarizerServiceProvider.overrideWithValue(mockService),
    ]);
    // Keep a listener alive to prevent auto-dispose.
    emittedStates = [];
    container.listen(
      summarizerControllerProvider,
      (prev, next) {
        emittedStates.add(next);
      },
      fireImmediately: true,
    );
  });

  tearDown(() {
    container.dispose();
  });

  SummaryState? currentState() {
    return container.read(summarizerControllerProvider).valueOrNull;
  }

  SummarizerController notifier() {
    return container.read(summarizerControllerProvider.notifier);
  }

  group('SummarizerController', () {
    test('build() returns SummaryIdle', () async {
      await container.read(summarizerControllerProvider.future);
      expect(currentState(), isA<SummaryIdle>());
    });

    test('summarizeText - happy path transitions to SummarySuccess', () async {
      await container.read(summarizerControllerProvider.future);
      mockService.streamChunks = ['Hello ', 'World'];

      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();

      final state = currentState();
      expect(state, isA<SummarySuccess>());
      final success = state as SummarySuccess;
      expect(success.summary.id, equals('test-summary-1'));
      expect(success.activeFormat, equals(SummaryFormat.bullets));
    });

    test('summarizeText - stream error transitions to SummaryError', () async {
      await container.read(summarizerControllerProvider.future);
      mockService.streamShouldError = true;
      mockService.streamError = const NetworkException();

      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();

      final state = currentState();
      expect(state, isA<SummaryError>());
      final error = state as SummaryError;
      expect(error.message, contains('internet'));
    });

    test(
        'summarizeText - TokenBudgetExceededException yields error with paywall message',
        () async {
      await container.read(summarizerControllerProvider.future);
      mockService.streamShouldError = true;
      mockService.streamError = const TokenBudgetExceededException();

      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();

      final state = currentState();
      expect(state, isA<SummaryError>());
      final error = state as SummaryError;
      expect(error.message, contains('tokens'));
    });

    test('switchFormat changes format without API call', () async {
      await container.read(summarizerControllerProvider.future);
      mockService.streamChunks = ['Hello'];

      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();
      expect(currentState(), isA<SummarySuccess>());

      mockService.callLog.clear();

      notifier().switchFormat(SummaryFormat.paragraph);

      final state = currentState();
      expect(state, isA<SummarySuccess>());
      expect(
          (state as SummarySuccess).activeFormat, equals(SummaryFormat.paragraph));
      expect(mockService.callLog, isEmpty);
    });

    test('switchFormat does nothing when not in success state', () async {
      await container.read(summarizerControllerProvider.future);

      notifier().switchFormat(SummaryFormat.paragraph);

      expect(currentState(), isA<SummaryIdle>());
    });

    test('cancel returns to idle', () async {
      await container.read(summarizerControllerProvider.future);

      mockService.streamChunks = [];
      final future =
          notifier().summarizeText('Some long text to summarize here');

      notifier().cancel();

      await future;
      await pumpEventQueue();

      expect(currentState(), isA<SummaryIdle>());
    });

    test('reset returns to idle from success', () async {
      await container.read(summarizerControllerProvider.future);
      mockService.streamChunks = ['Hello'];

      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();
      expect(currentState(), isA<SummarySuccess>());

      notifier().reset();

      expect(currentState(), isA<SummaryIdle>());
    });

    test('summarizeUrl - happy path transitions to SummarySuccess', () async {
      await container.read(summarizerControllerProvider.future);
      mockService.streamChunks = ['chunk1'];

      await notifier().summarizeUrl('https://example.com');
      await pumpEventQueue();

      expect(currentState(), isA<SummarySuccess>());
    });

    test('summarizeUrl - error transitions to SummaryError', () async {
      await container.read(summarizerControllerProvider.future);
      mockService.streamShouldError = true;
      mockService.streamError =
          const UrlParsingException(url: 'https://example.com');

      await notifier().summarizeUrl('https://example.com');
      await pumpEventQueue();

      expect(currentState(), isA<SummaryError>());
    });

    test('summarizePdf - happy path transitions to SummarySuccess', () async {
      await container.read(summarizerControllerProvider.future);

      await notifier().summarizePdf(Uint8List.fromList([1, 2, 3]), 'test.pdf');

      expect(currentState(), isA<SummarySuccess>());
    });

    test('summarizePdf - error transitions to SummaryError', () async {
      await container.read(summarizerControllerProvider.future);
      mockService.errorToThrow = const PdfParsingException();

      await notifier().summarizePdf(Uint8List.fromList([1, 2, 3]), 'test.pdf');

      final state = currentState();
      expect(state, isA<SummaryError>());
      expect((state as SummaryError).message, contains('PDF'));
    });

    test('summarizeText sets loading state before streaming', () async {
      await container.read(summarizerControllerProvider.future);
      emittedStates.clear();

      mockService.streamChunks = ['Hello'];
      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();

      final innerStates = emittedStates
          .map((e) => e.valueOrNull)
          .whereType<SummaryState>()
          .toList();
      expect(innerStates.first, isA<SummaryLoading>());
    });

    test('streaming produces SummaryStreaming states with partial content',
        () async {
      await container.read(summarizerControllerProvider.future);
      emittedStates.clear();

      mockService.streamChunks = ['Hello ', 'World'];
      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();

      final innerStates = emittedStates
          .map((e) => e.valueOrNull)
          .whereType<SummaryStreaming>()
          .toList();
      expect(innerStates, isNotEmpty);
      expect(innerStates.last.partialContent, contains('Hello'));
    });

    test('error state contains meaningful message for generic exception',
        () async {
      await container.read(summarizerControllerProvider.future);
      mockService.streamShouldError = true;
      mockService.streamError = Exception('Something went wrong');

      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();

      final state = currentState();
      expect(state, isA<SummaryError>());
      expect((state as SummaryError).message, isNotEmpty);
    });

    test('summarizeText after error - can recover and summarize again',
        () async {
      await container.read(summarizerControllerProvider.future);

      mockService.streamShouldError = true;
      mockService.streamError = const NetworkException();
      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();
      expect(currentState(), isA<SummaryError>());

      mockService.streamShouldError = false;
      mockService.streamChunks = ['recovered'];
      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();
      expect(currentState(), isA<SummarySuccess>());
    });

    test(
        'summarizeText - onDone error transitions to SummaryError after streaming',
        () async {
      await container.read(summarizerControllerProvider.future);

      mockService.streamChunks = ['Hello'];
      mockService.errorToThrow =
          const ApiException('Server error', statusCode: 500);

      await notifier().summarizeText('Some long text to summarize here');
      await pumpEventQueue();

      final state = currentState();
      expect(state, isA<SummaryError>());
      expect((state as SummaryError).message, contains('Server error'));
    });
  });
}
