import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/summary_model.dart';
import '../utils/exceptions.dart';
import '../utils/summary_format.dart';

/// Pure-Dart service for summarising content via the Cloud Functions backend.
///
/// All AI API calls go through our backend — no API keys in the client.
/// Accepts a [Dio] instance for easy testing with mocks.
class SummarizerService {
  final Dio _dio;

  SummarizerService({required Dio dio}) : _dio = dio;

  // ---------------------------------------------------------------------------
  // Summarise (request/response)
  // ---------------------------------------------------------------------------

  /// Summarise raw text content.
  Future<SummaryModel> summarizeText(
    String text, {
    SummaryFormat format = SummaryFormat.bullets,
  }) async {
    _validateText(text);
    return _postSummarize(
      path: '/summarize/text',
      body: {'text': text, 'format': format.name},
    );
  }

  /// Summarise the contents at [url] (server extracts readable content).
  Future<SummaryModel> summarizeUrl(
    String url, {
    SummaryFormat format = SummaryFormat.bullets,
  }) async {
    if (url.trim().isEmpty) {
      throw const ContentTooShortException('URL cannot be empty.');
    }
    return _postSummarize(
      path: '/summarize/url',
      body: {'url': url, 'format': format.name},
    );
  }

  /// Summarise an uploaded PDF.
  Future<SummaryModel> summarizePdf(
    Uint8List pdfBytes,
    String fileName, {
    SummaryFormat format = SummaryFormat.bullets,
  }) async {
    if (pdfBytes.isEmpty) {
      throw const PdfParsingException('PDF data is empty.');
    }
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(pdfBytes, filename: fileName),
      'format': format.name,
    });
    return _postSummarize(
      path: '/summarize/pdf',
      body: formData,
      isMultipart: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Streaming
  // ---------------------------------------------------------------------------

  /// Summarise text with a streaming (SSE / chunked) response.
  ///
  /// Yields partial content chunks as they arrive, allowing the UI to
  /// display a typing effect.
  Stream<String> summarizeTextStream(String text) {
    _validateText(text);
    return _streamSummarize(
      path: '/summarize/text/stream',
      body: {'text': text},
    );
  }

  /// Summarise URL content with a streaming response.
  Stream<String> summarizeUrlStream(String url) {
    if (url.trim().isEmpty) {
      throw const ContentTooShortException('URL cannot be empty.');
    }
    return _streamSummarize(
      path: '/summarize/url/stream',
      body: {'url': url},
    );
  }

  // ---------------------------------------------------------------------------
  // Client-side format conversions
  // ---------------------------------------------------------------------------

  /// Split raw content into bullet-point lines.
  List<String> toBullets(String content) {
    if (content.trim().isEmpty) return [];
    return content
        .split(RegExp(r'\n+'))
        .map((line) => line.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Merge content lines into a single paragraph.
  String toParagraph(String content) {
    if (content.trim().isEmpty) return '';
    return content
        .split(RegExp(r'\n+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .join(' ');
  }

  /// Extract key takeaways from content.
  ///
  /// Looks for lines starting with numbered markers or returns plain
  /// bullet-split lines.
  List<String> toTakeaways(String content) {
    if (content.trim().isEmpty) return [];
    return content
        .split(RegExp(r'\n+'))
        .map((line) => line.replaceFirst(RegExp(r'^\d+[.)]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Extract action items from content.
  List<String> toActionItems(String content) {
    if (content.trim().isEmpty) return [];
    return content
        .split(RegExp(r'\n+'))
        .map((line) =>
            line.replaceFirst(RegExp(r'^[-*•\[\]x]\s*', caseSensitive: false), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _validateText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.split(RegExp(r'\s+')).length < 3) {
      throw const ContentTooShortException();
    }
  }

  Future<SummaryModel> _postSummarize({
    required String path,
    required dynamic body,
    bool isMultipart = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        options: isMultipart
            ? Options(contentType: 'multipart/form-data')
            : null,
      );

      if (response.data == null) {
        throw const ApiException('Empty response from server.');
      }

      return SummaryModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Stream<String> _streamSummarize({
    required String path,
    required Map<String, dynamic> body,
  }) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        path,
        data: body,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw const ApiException('No stream received from server.');
      }

      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        // SSE format: each event starts with "data: "
        for (final line in text.split('\n')) {
          if (line.startsWith('data: ')) {
            final payload = line.substring(6).trim();
            if (payload == '[DONE]') return;
            yield payload;
          } else if (line.isNotEmpty && !line.startsWith(':')) {
            // Fallback for plain chunked responses.
            yield line;
          }
        }
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Map [DioException] to domain exceptions.
  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final body = e.response?.data;
        final message =
            body is Map ? (body['error'] as String? ?? 'Server error') : 'Server error';
        if (status == 429) {
          return const TokenBudgetExceededException();
        }
        if (status == 413) {
          return const ContentTooLongException(
            maxWords: 0,
            actualWords: 0,
            message: 'Content exceeds the maximum allowed size.',
          );
        }
        if (status == 422 && message.contains('url')) {
          return UrlParsingException(url: '', message: message);
        }
        return ApiException(message, statusCode: status, originalError: e);
      default:
        return ApiException(
          e.message ?? 'Unexpected network error.',
          originalError: e,
        );
    }
  }
}
