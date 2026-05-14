import 'dart:async';

import 'package:ai_master/controllers/expert_controller.dart';
import 'package:ai_master/controllers/providers.dart';
import 'package:ai_master/controllers/states.dart';
import 'package:ai_master/models/expert_model.dart';
import 'package:ai_master/services/expert_service.dart';
import 'package:ai_master/models/subscription_model.dart';
import 'package:ai_master/utils/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_services.dart';
import '../helpers/test_factories.dart';

// =============================================================================
// Mock ExpertService
// =============================================================================

class MockExpertService implements ExpertService {
  ExpertMessage? messageToReturn;
  List<String> streamChunks = [];
  bool streamShouldError = false;
  Object streamError = Exception('Stream error');
  bool shouldThrow = false;
  Object errorToThrow = Exception('ExpertService error');
  final List<String> callLog = [];

  MockExpertService() {
    messageToReturn = TestFactories.createAssistantMessage();
  }

  void reset() {
    messageToReturn = TestFactories.createAssistantMessage();
    streamChunks = [];
    streamShouldError = false;
    shouldThrow = false;
    callLog.clear();
  }

  @override
  Future<ExpertMessage> sendQuery(
    ExpertType expert,
    String message,
    List<ExpertMessage> history,
  ) async {
    callLog.add('sendQuery');
    if (shouldThrow) throw errorToThrow;
    return messageToReturn!;
  }

  @override
  Stream<String> sendQueryStream(
    ExpertType expert,
    String message,
    List<ExpertMessage> history,
  ) {
    callLog.add('sendQueryStream');
    if (streamShouldError) {
      return Stream.error(streamError);
    }
    return _asyncStream(streamChunks);
  }

  @override
  List<ExpertModel> getAvailableExperts(SubscriptionTier tier) {
    callLog.add('getAvailableExperts');
    return TestFactories.createExpertList();
  }

  @override
  String getSystemPrompt(ExpertType expert) {
    return 'Mock system prompt for ${expert.name}';
  }
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
  late MockExpertService mockExpertService;
  late MockLibraryStorage mockLibraryStorage;
  late ProviderContainer container;

  setUp(() {
    mockExpertService = MockExpertService();
    mockLibraryStorage = MockLibraryStorage();

    container = ProviderContainer(overrides: [
      expertServiceProvider.overrideWithValue(mockExpertService),
      libraryStorageAdapter.overrideWithValue(mockLibraryStorage),
    ]);

    // Keep a listener alive to prevent auto-dispose.
    container.listen(
      expertControllerProvider,
      (prev, next) {},
      fireImmediately: true,
    );
  });

  tearDown(() {
    container.dispose();
  });

  ExpertController notifier() {
    return container.read(expertControllerProvider.notifier);
  }

  ExpertChatState? currentState() {
    return container.read(expertControllerProvider).valueOrNull;
  }

  group('ExpertController', () {
    test('build() returns default ExpertChatState', () async {
      final state = await container.read(expertControllerProvider.future);

      expect(state.expert, equals(ExpertType.writingAssistant));
      expect(state.messages, isEmpty);
      expect(state.isStreaming, isFalse);
    });

    test('selectExpert updates expert and clears history', () async {
      await container.read(expertControllerProvider.future);

      // First add a message.
      mockExpertService.streamChunks = ['response'];
      await notifier().sendMessage('Hello');
      await pumpEventQueue();
      expect(currentState()!.messages, isNotEmpty);

      // Now switch expert.
      notifier().selectExpert(ExpertType.fitness);

      final state = currentState()!;
      expect(state.expert, equals(ExpertType.fitness));
      expect(state.messages, isEmpty);
      expect(state.isStreaming, isFalse);
    });

    test('sendMessage adds user message and AI response', () async {
      await container.read(expertControllerProvider.future);
      mockExpertService.streamChunks = ['Hello ', 'from AI'];

      await notifier().sendMessage('Give me a workout plan');
      await pumpEventQueue();

      final state = currentState()!;
      expect(state.messages.length, equals(2)); // user + assistant
      expect(state.messages.first.role, equals(MessageRole.user));
      expect(state.messages.first.content, equals('Give me a workout plan'));
      expect(state.messages.last.role, equals(MessageRole.assistant));
      expect(state.messages.last.content, equals('Hello from AI'));
      expect(state.isStreaming, isFalse);
    });

    test('sendMessage with empty text is a no-op', () async {
      await container.read(expertControllerProvider.future);

      await notifier().sendMessage('   ');

      final state = currentState()!;
      expect(state.messages, isEmpty);
      expect(mockExpertService.callLog, isEmpty);
    });

    test('sendMessage - stream error reverts to non-streaming', () async {
      await container.read(expertControllerProvider.future);
      mockExpertService.streamShouldError = true;
      mockExpertService.streamError = const NetworkException();

      await notifier().sendMessage('Hello');
      await pumpEventQueue();

      final state = currentState()!;
      expect(state.isStreaming, isFalse);
      // User message should still be present.
      expect(state.messages.length, equals(1));
      expect(state.messages.first.role, equals(MessageRole.user));
    });

    test('sendMessage - catch block error keeps user message', () async {
      await container.read(expertControllerProvider.future);

      mockExpertService.streamShouldError = true;
      mockExpertService.streamError = Exception('Connection refused');

      await notifier().sendMessage('Hello');
      await pumpEventQueue();

      final state = currentState()!;
      expect(state.isStreaming, isFalse);
      expect(state.messages, isNotEmpty);
      expect(state.messages.first.role, equals(MessageRole.user));
    });

    test('switching expert mid-conversation clears messages', () async {
      await container.read(expertControllerProvider.future);
      mockExpertService.streamChunks = ['response1'];

      await notifier().sendMessage('Hello');
      await pumpEventQueue();
      expect(currentState()!.messages, hasLength(2));

      // Switch expert.
      notifier().selectExpert(ExpertType.chef);

      expect(currentState()!.messages, isEmpty);
      expect(currentState()!.expert, equals(ExpertType.chef));

      // Send new message to new expert.
      mockExpertService.streamChunks = ['recipe'];
      await notifier().sendMessage('What should I cook?');
      await pumpEventQueue();

      expect(currentState()!.messages, hasLength(2));
      expect(currentState()!.expert, equals(ExpertType.chef));
    });

    test('saveResponseToLibrary calls library service', () async {
      await container.read(expertControllerProvider.future);

      final message = TestFactories.createAssistantMessage(
        content: 'Here is your workout plan.',
      );

      await notifier().saveResponseToLibrary(message);

      expect(mockLibraryStorage.callLog, contains('put'));
      final stored = await mockLibraryStorage.getAll();
      expect(stored, isNotEmpty);
      expect(stored.first['title'], contains('Expert'));
    });

    test('saveResponseToLibrary throws on storage error', () async {
      await container.read(expertControllerProvider.future);
      mockLibraryStorage.shouldThrow = true;

      final message = TestFactories.createAssistantMessage();

      expect(
        () => notifier().saveResponseToLibrary(message),
        throwsA(isA<AppException>()),
      );
    });

    test('sendMessage sets isStreaming true during streaming', () async {
      await container.read(expertControllerProvider.future);

      final streamingStates = <bool>[];
      container.listen(
        expertControllerProvider,
        (prev, next) {
          final val = next.valueOrNull;
          if (val != null) {
            streamingStates.add(val.isStreaming);
          }
        },
        fireImmediately: false,
      );

      mockExpertService.streamChunks = ['Hello'];
      await notifier().sendMessage('Hi');
      await pumpEventQueue();

      expect(streamingStates, contains(true));
      expect(currentState()!.isStreaming, isFalse);
    });

    test('multiple messages accumulate in history', () async {
      await container.read(expertControllerProvider.future);

      mockExpertService.streamChunks = ['response1'];
      await notifier().sendMessage('First question');
      await pumpEventQueue();

      mockExpertService.streamChunks = ['response2'];
      await notifier().sendMessage('Follow up question');
      await pumpEventQueue();

      final state = currentState()!;
      expect(state.messages, hasLength(4));
      expect(state.messages[0].role, equals(MessageRole.user));
      expect(state.messages[1].role, equals(MessageRole.assistant));
      expect(state.messages[2].role, equals(MessageRole.user));
      expect(state.messages[3].role, equals(MessageRole.assistant));
    });

    test('selectExpert to same type still clears messages', () async {
      await container.read(expertControllerProvider.future);
      mockExpertService.streamChunks = ['resp'];

      await notifier().sendMessage('Hello');
      await pumpEventQueue();
      expect(currentState()!.messages, isNotEmpty);

      notifier().selectExpert(ExpertType.writingAssistant);

      expect(currentState()!.messages, isEmpty);
      expect(currentState()!.expert, equals(ExpertType.writingAssistant));
    });
  });
}
