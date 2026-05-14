import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/summary_model.dart';
import '../utils/exceptions.dart';
import '../utils/summary_format.dart';
import 'providers.dart';
import 'states.dart';

/// Controller that bridges [SummarizerService] to the UI.
///
/// Manages the full lifecycle of a summarisation request: idle -> loading /
/// streaming -> success | error.  Also supports client-side format switching
/// and cancellation.
class SummarizerController extends AutoDisposeAsyncNotifier<SummaryState> {
  StreamSubscription<String>? _streamSubscription;

  @override
  Future<SummaryState> build() async => const SummaryIdle();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Summarise raw text input.
  Future<void> summarizeText(String text) async {
    state = const AsyncData(SummaryLoading());
    try {
      final service = ref.read(summarizerServiceProvider);
      final buffer = StringBuffer();

      _streamSubscription?.cancel();
      _streamSubscription = service.summarizeTextStream(text).listen(
        (chunk) {
          buffer.write(chunk);
          state = AsyncData(SummaryStreaming(partialContent: buffer.toString()));
        },
        onError: (Object error) {
          state = AsyncData(SummaryError(
            message: error is AppException ? error.message : error.toString(),
          ));
        },
        onDone: () async {
          // Fetch the full structured summary after streaming completes.
          try {
            final summary = await service.summarizeText(text);
            state = AsyncData(SummarySuccess(summary: summary));
          } catch (e) {
            state = AsyncData(SummaryError(
              message: e is AppException ? e.message : e.toString(),
            ));
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      state = AsyncData(SummaryError(
        message: e is AppException ? e.message : e.toString(),
      ));
    }
  }

  /// Summarise content at a URL.
  Future<void> summarizeUrl(String url) async {
    state = const AsyncData(SummaryLoading());
    try {
      final service = ref.read(summarizerServiceProvider);
      final buffer = StringBuffer();

      _streamSubscription?.cancel();
      _streamSubscription = service.summarizeUrlStream(url).listen(
        (chunk) {
          buffer.write(chunk);
          state = AsyncData(SummaryStreaming(partialContent: buffer.toString()));
        },
        onError: (Object error) {
          state = AsyncData(SummaryError(
            message: error is AppException ? error.message : error.toString(),
          ));
        },
        onDone: () async {
          try {
            final summary = await service.summarizeUrl(url);
            state = AsyncData(SummarySuccess(summary: summary));
          } catch (e) {
            state = AsyncData(SummaryError(
              message: e is AppException ? e.message : e.toString(),
            ));
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      state = AsyncData(SummaryError(
        message: e is AppException ? e.message : e.toString(),
      ));
    }
  }

  /// Summarise an uploaded PDF file.
  Future<void> summarizePdf(Uint8List bytes, String fileName) async {
    state = const AsyncData(SummaryLoading());
    try {
      final service = ref.read(summarizerServiceProvider);
      final summary = await service.summarizePdf(bytes, fileName);
      state = AsyncData(SummarySuccess(summary: summary));
    } catch (e) {
      state = AsyncData(SummaryError(
        message: e is AppException ? e.message : e.toString(),
      ));
    }
  }

  /// Switch the active display format on an existing result.
  ///
  /// This is a client-side operation — no network call required because
  /// [SummaryModel] already contains all format variants.
  void switchFormat(SummaryFormat format) {
    final current = state.valueOrNull;
    if (current is SummarySuccess) {
      state = AsyncData(SummarySuccess(
        summary: current.summary,
        activeFormat: format,
      ));
    }
  }

  /// Cancel an in-progress summarisation (streaming or request).
  void cancel() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    state = const AsyncData(SummaryIdle());
  }

  /// Reset back to idle state.
  void reset() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    state = const AsyncData(SummaryIdle());
  }
}
