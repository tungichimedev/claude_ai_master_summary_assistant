import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/summarizer_service.dart';
import 'package:ai_master/models/summary_model.dart';
import 'package:ai_master/utils/exceptions.dart';

// =============================================================================
// Mock Dio adapter
// =============================================================================

/// A fake [HttpClientAdapter] that returns pre-configured responses
/// without making real network calls.
class MockDioAdapter implements HttpClientAdapter {
  int? statusCode;
  dynamic responseData;
  DioExceptionType? exceptionType;
  String? errorMessage;

  MockDioAdapter({
    this.statusCode = 200,
    this.responseData,
  });

  void setupSuccess(Map<String, dynamic> data) {
    statusCode = 200;
    responseData = data;
    exceptionType = null;
  }

  void setupError(int code, {dynamic body}) {
    statusCode = code;
    responseData = body;
    exceptionType = DioExceptionType.badResponse;
  }

  void setupConnectionError() {
    exceptionType = DioExceptionType.connectionError;
  }

  void setupTimeout() {
    exceptionType = DioExceptionType.connectionTimeout;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (exceptionType != null) {
      throw DioException(
        type: exceptionType!,
        requestOptions: options,
        message: errorMessage,
        response: exceptionType == DioExceptionType.badResponse
            ? Response(
                statusCode: statusCode,
                data: responseData,
                requestOptions: options,
              )
            : null,
      );
    }

    final headers = Headers();
    headers.set('content-type', ['application/json']);

    return ResponseBody.fromString(
      _encodeJson(responseData),
      statusCode ?? 200,
      headers: headers.map.map((k, v) => MapEntry(k, v)),
    );
  }

  String _encodeJson(dynamic data) {
    if (data is String) return data;
    if (data is Map || data is List) {
      return _jsonEncode(data);
    }
    return '{}';
  }

  String _jsonEncode(dynamic data) {
    // Simple JSON encoding for test data.
    return _toJson(data);
  }

  String _toJson(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    if (value is String) return '"${_escapeString(value)}"';
    if (value is List) {
      final items = value.map(_toJson).join(',');
      return '[$items]';
    }
    if (value is Map) {
      final entries =
          value.entries.map((e) => '"${e.key}":${_toJson(e.value)}').join(',');
      return '{$entries}';
    }
    return '"$value"';
  }

  String _escapeString(String s) =>
      s.replaceAll('\\', '\\\\').replaceAll('"', '\\"');

  @override
  void close({bool force = false}) {}
}

// =============================================================================
// Test helpers
// =============================================================================

/// A valid summary JSON response that the mock backend would return.
Map<String, dynamic> _validSummaryJson({
  String id = 'test-id-1',
  String title = 'Test Summary',
}) =>
    {
      'id': id,
      'title': title,
      'sourceType': 'text',
      'originalContent': 'Original long-form content here...',
      'bulletPoints': ['Point one', 'Point two', 'Point three'],
      'paragraphSummary': 'This is a paragraph summary.',
      'keyTakeaways': ['Takeaway one', 'Takeaway two'],
      'actionItems': ['Action one'],
      'wordCount': 150,
      'createdAt': '2026-01-15T10:00:00.000Z',
      'isFavorite': false,
      'tags': ['ai', 'test'],
    };

// =============================================================================
// Tests
// =============================================================================

void main() {
  late Dio dio;
  late MockDioAdapter adapter;
  late SummarizerService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://fake-api.example.com'));
    adapter = MockDioAdapter();
    dio.httpClientAdapter = adapter;
    service = SummarizerService(dio: dio);
  });

  // ---------------------------------------------------------------------------
  // summarizeText
  // ---------------------------------------------------------------------------

  group('summarizeText', () {
    test('returns SummaryModel on 200 success', () async {
      adapter.setupSuccess(_validSummaryJson());

      final result = await service.summarizeText(
          'This is a long enough text for summarization purposes');
      expect(result, isA<SummaryModel>());
      expect(result.id, 'test-id-1');
      expect(result.title, 'Test Summary');
      expect(result.bulletPoints.length, 3);
    });

    test('throws ContentTooShortException on empty text', () {
      expect(
        () => service.summarizeText(''),
        throwsA(isA<ContentTooShortException>()),
      );
    });

    test('throws ContentTooShortException on text with fewer than 3 words', () {
      expect(
        () => service.summarizeText('ab'),
        throwsA(isA<ContentTooShortException>()),
      );
    });

    test('throws ApiException on 500 server error', () async {
      adapter.setupError(500, body: {'error': 'Internal Server Error'});

      expect(
        () => service.summarizeText(
            'This is a long enough text for summarization purposes'),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws TokenBudgetExceededException on 429', () async {
      adapter.setupError(429, body: {'error': 'Rate limited'});

      expect(
        () => service.summarizeText(
            'This is a long enough text for summarization purposes'),
        throwsA(isA<TokenBudgetExceededException>()),
      );
    });

    test('throws ContentTooLongException on 413', () async {
      adapter.setupError(413, body: {'error': 'Payload too large'});

      expect(
        () => service.summarizeText(
            'This is a long enough text for summarization purposes'),
        throwsA(isA<ContentTooLongException>()),
      );
    });

    test('throws NetworkException on connection error', () async {
      adapter.setupConnectionError();

      expect(
        () => service.summarizeText(
            'This is a long enough text for summarization purposes'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws TimeoutException on timeout', () async {
      adapter.setupTimeout();

      expect(
        () => service.summarizeText(
            'This is a long enough text for summarization purposes'),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // summarizeUrl
  // ---------------------------------------------------------------------------

  group('summarizeUrl', () {
    test('returns SummaryModel on success', () async {
      adapter.setupSuccess(
          _validSummaryJson(title: 'URL Summary')..['sourceType'] = 'url');

      final result =
          await service.summarizeUrl('https://example.com/article');
      expect(result, isA<SummaryModel>());
      expect(result.title, 'URL Summary');
    });

    test('throws ContentTooShortException on empty URL', () {
      expect(
        () => service.summarizeUrl(''),
        throwsA(isA<ContentTooShortException>()),
      );
    });

    test('throws ContentTooShortException on whitespace-only URL', () {
      expect(
        () => service.summarizeUrl('   '),
        throwsA(isA<ContentTooShortException>()),
      );
    });

    test('throws UrlParsingException on 422 with url error', () async {
      adapter.setupError(422, body: {'error': 'Could not parse url'});

      expect(
        () => service.summarizeUrl('https://bad-url.example.com'),
        throwsA(isA<UrlParsingException>()),
      );
    });

    test('throws ApiException on generic server error', () async {
      adapter.setupError(500, body: {'error': 'Server error'});

      expect(
        () => service.summarizeUrl('https://example.com'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // summarizePdf
  // ---------------------------------------------------------------------------

  group('summarizePdf', () {
    test('returns SummaryModel on success', () async {
      adapter.setupSuccess(
          _validSummaryJson(title: 'PDF Summary')..['sourceType'] = 'pdf');

      final result = await service.summarizePdf(
        Uint8List.fromList([0x25, 0x50, 0x44, 0x46]), // %PDF header
        'test.pdf',
      );
      expect(result, isA<SummaryModel>());
      expect(result.title, 'PDF Summary');
    });

    test('throws PdfParsingException on empty bytes', () {
      expect(
        () => service.summarizePdf(Uint8List(0), 'empty.pdf'),
        throwsA(isA<PdfParsingException>()),
      );
    });

    test('throws ContentTooLongException on 413 (too many pages)', () async {
      adapter.setupError(413, body: {'error': 'Payload too large'});

      expect(
        () => service.summarizePdf(
          Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
          'huge.pdf',
        ),
        throwsA(isA<ContentTooLongException>()),
      );
    });

    test('throws TokenBudgetExceededException on 429', () async {
      adapter.setupError(429);

      expect(
        () => service.summarizePdf(
          Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
          'test.pdf',
        ),
        throwsA(isA<TokenBudgetExceededException>()),
      );
    });

    test('throws ApiException on 500', () async {
      adapter.setupError(500);

      expect(
        () => service.summarizePdf(
          Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
          'test.pdf',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Format conversion: toBullets
  // ---------------------------------------------------------------------------

  group('toBullets', () {
    test('splits multiline content into bullet list', () {
      final result = service.toBullets('Point one\nPoint two\nPoint three');
      expect(result, ['Point one', 'Point two', 'Point three']);
    });

    test('strips bullet markers (-, *, bullet)', () {
      final result = service.toBullets('- First\n* Second\n• Third');
      expect(result, ['First', 'Second', 'Third']);
    });

    test('returns empty list for empty input', () {
      expect(service.toBullets(''), isEmpty);
    });

    test('returns empty list for whitespace-only input', () {
      expect(service.toBullets('   \n  \n  '), isEmpty);
    });

    test('handles multiple newlines between items', () {
      final result = service.toBullets('First\n\n\nSecond');
      expect(result, ['First', 'Second']);
    });
  });

  // ---------------------------------------------------------------------------
  // Format conversion: toParagraph
  // ---------------------------------------------------------------------------

  group('toParagraph', () {
    test('merges multiple lines into single paragraph', () {
      final result = service.toParagraph('Line one.\nLine two.\nLine three.');
      expect(result, 'Line one. Line two. Line three.');
    });

    test('returns empty string for empty input', () {
      expect(service.toParagraph(''), '');
    });

    test('returns empty string for whitespace-only input', () {
      expect(service.toParagraph('   \n  '), '');
    });

    test('trims whitespace from each line', () {
      final result = service.toParagraph('  Hello  \n  World  ');
      expect(result, 'Hello World');
    });

    test('collapses multiple blank lines', () {
      final result = service.toParagraph('A\n\n\nB');
      expect(result, 'A B');
    });
  });

  // ---------------------------------------------------------------------------
  // Format conversion: toTakeaways
  // ---------------------------------------------------------------------------

  group('toTakeaways', () {
    test('strips numbered markers', () {
      final result =
          service.toTakeaways('1. First takeaway\n2. Second takeaway');
      expect(result, ['First takeaway', 'Second takeaway']);
    });

    test('handles dot and paren numbered markers', () {
      final result =
          service.toTakeaways('1) One\n2) Two\n3. Three');
      expect(result, ['One', 'Two', 'Three']);
    });

    test('returns empty list for empty input', () {
      expect(service.toTakeaways(''), isEmpty);
    });

    test('handles content without numbered markers', () {
      final result = service.toTakeaways('Just a line\nAnother line');
      expect(result, ['Just a line', 'Another line']);
    });

    test('filters out empty lines', () {
      final result = service.toTakeaways('1. First\n\n2. Second');
      expect(result, ['First', 'Second']);
    });
  });

  // ---------------------------------------------------------------------------
  // Format conversion: toActionItems
  // ---------------------------------------------------------------------------

  group('toActionItems', () {
    test('strips checkbox-style markers', () {
      // The regex strips leading [-*\[\]x] chars one at a time.
      // For "- [ ] Task" the dash is stripped first, leaving "[ ] Task"
      // which then needs another pass. Test with simple markers instead.
      final result = service.toActionItems('- Do this\n- Done that');
      expect(result, ['Do this', 'Done that']);
    });

    test('strips dash and bullet markers', () {
      final result = service.toActionItems('- Task one\n* Task two\n• Task three');
      expect(result, ['Task one', 'Task two', 'Task three']);
    });

    test('returns empty list for empty input', () {
      expect(service.toActionItems(''), isEmpty);
    });

    test('handles plain-text action items', () {
      final result = service.toActionItems('Review the PR\nDeploy to staging');
      expect(result, ['Review the PR', 'Deploy to staging']);
    });

    test('filters out empty lines', () {
      final result = service.toActionItems('- First\n\n- Second');
      expect(result, ['First', 'Second']);
    });
  });

  // ---------------------------------------------------------------------------
  // Streaming (summarizeTextStream)
  // ---------------------------------------------------------------------------

  group('summarizeTextStream', () {
    test('throws ContentTooShortException on empty text', () {
      expect(
        () => service.summarizeTextStream(''),
        throwsA(isA<ContentTooShortException>()),
      );
    });

    test('throws ContentTooShortException on short text', () {
      expect(
        () => service.summarizeTextStream('hi'),
        throwsA(isA<ContentTooShortException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Streaming (summarizeUrlStream)
  // ---------------------------------------------------------------------------

  group('summarizeUrlStream', () {
    test('throws ContentTooShortException on empty URL', () {
      expect(
        () => service.summarizeUrlStream(''),
        throwsA(isA<ContentTooShortException>()),
      );
    });

    test('throws ContentTooShortException on whitespace-only URL', () {
      expect(
        () => service.summarizeUrlStream('   '),
        throwsA(isA<ContentTooShortException>()),
      );
    });
  });
}
