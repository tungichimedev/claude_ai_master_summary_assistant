import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/expert_model.dart';
import '../models/summary_model.dart';
import '../utils/exceptions.dart';
import 'providers.dart';
import 'states.dart';

const _uuid = Uuid();

/// Controller for AI Expert chat sessions.
///
/// Manages the active expert selection, conversation history, and streaming
/// responses.
class ExpertController extends AutoDisposeAsyncNotifier<ExpertChatState> {
  StreamSubscription<String>? _streamSubscription;

  @override
  Future<ExpertChatState> build() async => const ExpertChatState();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Send a user message to the currently selected expert.
  ///
  /// Streams the response back, updating [ExpertChatState.messages] in
  /// real-time as chunks arrive.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final current = state.valueOrNull ?? const ExpertChatState();
    final expertService = ref.read(expertServiceProvider);

    // Add user message to history.
    final userMessage = ExpertMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: text.trim(),
      timestamp: DateTime.now(),
    );
    final updatedMessages = [...current.messages, userMessage];
    state = AsyncData(current.copyWith(
      messages: updatedMessages,
      isStreaming: true,
    ));

    // Stream the assistant response.
    final buffer = StringBuffer();
    final assistantId = _uuid.v4();

    try {
      _streamSubscription?.cancel();
      _streamSubscription = expertService
          .sendQueryStream(current.expert, text, updatedMessages)
          .listen(
        (chunk) {
          buffer.write(chunk);
          // Update the last assistant message in-place with partial content.
          final partial = ExpertMessage(
            id: assistantId,
            role: MessageRole.assistant,
            content: buffer.toString(),
            timestamp: DateTime.now(),
          );
          final msgs = [...updatedMessages, partial];
          state = AsyncData(current.copyWith(
            messages: msgs,
            isStreaming: true,
          ));
        },
        onError: (Object error) {
          state = AsyncData(current.copyWith(
            messages: updatedMessages,
            isStreaming: false,
          ));
        },
        onDone: () {
          // Finalise the assistant message.
          final finalMessage = ExpertMessage(
            id: assistantId,
            role: MessageRole.assistant,
            content: buffer.toString(),
            timestamp: DateTime.now(),
          );
          final msgs = [...updatedMessages, finalMessage];
          state = AsyncData(current.copyWith(
            messages: msgs,
            isStreaming: false,
          ));
        },
        cancelOnError: true,
      );
    } catch (e) {
      state = AsyncData(current.copyWith(
        messages: updatedMessages,
        isStreaming: false,
      ));
    }
  }

  /// Switch to a different expert persona. Clears the conversation history.
  void selectExpert(ExpertType type) {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    state = AsyncData(ExpertChatState(expert: type));
  }

  /// Save an expert's response as a summary in the library.
  Future<void> saveResponseToLibrary(ExpertMessage message) async {
    try {
      final library = ref.read(libraryServiceProvider);
      final current = state.valueOrNull ?? const ExpertChatState();

      final summary = SummaryModel(
        id: _uuid.v4(),
        title: 'Expert: ${_expertLabel(current.expert)}',
        sourceType: SummarySourceType.text,
        originalContent: message.content,
        bulletPoints: message.content
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .toList(),
        paragraphSummary: message.content,
        keyTakeaways: const [],
        actionItems: const [],
        wordCount: message.content.split(RegExp(r'\s+')).length,
        createdAt: DateTime.now(),
        tags: ['expert', current.expert.name],
        sourceName: _expertLabel(current.expert),
      );

      await library.saveSummary(summary);
    } catch (e) {
      // Surface error via state so the UI can show a snackbar.
      throw e is AppException
          ? e
          : UnexpectedException(e.toString(), e);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _expertLabel(ExpertType type) {
    switch (type) {
      case ExpertType.socialMedia:
        return 'Social Media Expert';
      case ExpertType.fitness:
        return 'Fitness Coach';
      case ExpertType.chef:
        return 'Expert Chef';
      case ExpertType.homeAdvisor:
        return 'Home Advisor';
      case ExpertType.salesCoach:
        return 'Sales Coach';
      case ExpertType.writingAssistant:
        return 'Writing Assistant';
    }
  }
}
