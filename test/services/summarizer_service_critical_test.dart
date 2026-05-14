import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/summarizer_service.dart';
import 'package:ai_master/models/summary_model.dart';
import 'package:ai_master/utils/exceptions.dart';

// =============================================================================
// Mock Dio adapter (same pattern as summarizer_service_test.dart)
// =============================================================================

class MockDioAdapter implements HttpClientAdapter {
  int? statusCode;
  dynamic responseData;
  DioExceptionType? exceptionType;
  String? errorMessage;
  int callCount = 0;

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

  void setupNullResponse() {
    statusCode = 200;
    responseData = null;
    exceptionType = null;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;

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
      _toJson(responseData),
      statusCode ?? 200,
      headers: headers.map.map((k, v) => MapEntry(k, v)),
    );
  }

  String _toJson(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    if (value is String) return '"${_escapeString(value)}"';
    if (value is List) return '[${value.map(_toJson).join(',')}]';
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

Map<String, dynamic> _validSummaryJson({
  String id = 'test-id-1',
  String title = 'Test Summary',
  List<String>? bulletPoints,
}) =>
    {
      'id': id,
      'title': title,
      'sourceType': 'text',
      'originalContent': 'Original long-form content here...',
      'bulletPoints': bulletPoints ?? ['Point one', 'Point two', 'Point three'],
      'paragraphSummary': 'This is a paragraph summary.',
      'keyTakeaways': ['Takeaway one', 'Takeaway two'],
      'actionItems': ['Action one'],
      'wordCount': 150,
      'createdAt': '2026-01-15T10:00:00.000Z',
      'isFavorite': false,
      'tags': ['ai', 'test'],
    };

const String _validText =
    'This is a long enough text for summarization purposes and testing';

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
  // Malformed / null response handling
  // ---------------------------------------------------------------------------

  group('malformed response handling', () {
    test('should not crash when API returns JSON missing required fields',
        () async {
      // A response with only partial fields — SummaryModel.fromJson should
      // handle this with its ?? defaults rather than crashing.
      adapter.setupSuccess({
        'id': 'partial-1',
        // Missing: title, bulletPoints, paragraphSummary, etc.
      });

      final result = await service.summarizeText(_validText);
      expect(result, isA<SummaryModel>());
      expect(result.id, 'partial-1');
      expect(result.title, ''); // default
      expect(result.bulletPoints, isEmpty); // default
    });

    test('should throw ApiException when response.data is null', () async {
      // The server returns 200 but with a null body.
      adapter.setupNullResponse();

      expect(
        () => service.summarizeText(_validText),
        throwsA(isA<ApiException>()),
      );
    });

    test('should handle response with empty bulletPoints array', () async {
      adapter.setupSuccess(_validSummaryJson(bulletPoints: []));

      final result = await service.summarizeText(_validText);
      expect(result, isA<SummaryModel>());
      expect(result.bulletPoints, isEmpty);
    });

    test('should handle response with missing optional lists', () async {
      adapter.setupSuccess({
        'id': 'no-lists',
        'title': 'No Lists',
        'sourceType': 'text',
        'originalContent': 'Content here',
        'paragraphSummary': 'Summary here',
        'wordCount': 10,
        'createdAt': '2026-01-15T10:00:00.000Z',
        // bulletPoints, keyTakeaways, actionItems, tags all missing
      });

      final result = await service.summarizeText(_validText);
      expect(result.bulletPoints, isEmpty);
      expect(result.keyTakeaways, isEmpty);
      expect(result.actionItems, isEmpty);
      expect(result.tags, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // HTTP error code mapping
  // ---------------------------------------------------------------------------

  group('HTTP error code mapping', () {
    test('should throw ApiException with statusCode on 401 Unauthorized',
        () async {
      adapter.setupError(401, body: {'error': 'Unauthorized'});

      try {
        await service.summarizeText(_validText);
        fail('Expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 401);
        expect(e.message, contains('Unauthorized'));
      }
    });

    test('should throw ContentTooLongException on 413', () async {
      adapter.setupError(413, body: {'error': 'Payload too large'});

      expect(
        () => service.summarizeText(_validText),
        throwsA(isA<ContentTooLongException>()),
      );
    });

    test('should throw TokenBudgetExceededException on 429', () async {
      adapter.setupError(429);

      expect(
        () => service.summarizeUrl('https://example.com/article'),
        throwsA(isA<TokenBudgetExceededException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // URL handling edge cases
  // ---------------------------------------------------------------------------

  group('URL edge cases', () {
    test('should accept URL with special characters (query params, fragments)',
        () async {
      adapter.setupSuccess(
        _validSummaryJson()..['sourceType'] = 'url',
      );

      final result = await service.summarizeUrl(
        'https://example.com/path%20with%20spaces?q=hello+world&lang=en#section-2',
      );
      expect(result, isA<SummaryModel>());
    });

    test('should accept URL with unicode characters', () async {
      adapter.setupSuccess(
        _validSummaryJson()..['sourceType'] = 'url',
      );

      final result = await service.summarizeUrl(
        'https://example.com/article/caf\u00e9',
      );
      expect(result, isA<SummaryModel>());
    });

    test('should accept URL with port number and path', () async {
      adapter.setupSuccess(
        _validSummaryJson()..['sourceType'] = 'url',
      );

      final result = await service.summarizeUrl(
        'https://localhost:8080/api/articles/42',
      );
      expect(result, isA<SummaryModel>());
    });

    // NOTE: The current implementation does not validate URL schemes client-side.
    // file:// and javascript:// URLs are sent to the server which should reject
    // them. This test documents that behavior — the server returns 422.
    test('should throw UrlParsingException for invalid URL rejected by server',
        () async {
      adapter.setupError(422, body: {'error': 'Could not parse url'});

      expect(
        () => service.summarizeUrl('file:///etc/passwd'),
        throwsA(isA<UrlParsingException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Input size edge cases
  // ---------------------------------------------------------------------------

  group('input size edge cases', () {
    test('should handle text with exactly 3 words (minimum boundary)',
        () async {
      adapter.setupSuccess(_validSummaryJson());

      // Exactly 3 words should pass validation.
      final result = await service.summarizeText('one two three');
      expect(result, isA<SummaryModel>());
    });

    test('should throw ContentTooShortException for 2-word input', () {
      expect(
        () => service.summarizeText('only two'),
        throwsA(isA<ContentTooShortException>()),
      );
    });

    test('should send extremely long input to server without client crash',
        () async {
      // Generate 10,000+ words of content.
      final longText = List.generate(10001, (i) => 'word$i').join(' ');
      adapter.setupSuccess(_validSummaryJson());

      final result = await service.summarizeText(longText);
      expect(result, isA<SummaryModel>());
    });

    test('should propagate 413 from server when content is too long', () async {
      final longText = List.generate(10001, (i) => 'word$i').join(' ');
      adapter.setupError(413, body: {'error': 'Payload too large'});

      expect(
        () => service.summarizeText(longText),
        throwsA(isA<ContentTooLongException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Concurrent calls
  // ---------------------------------------------------------------------------

  group('concurrent summarize calls', () {
    test('should handle concurrent calls without shared state corruption',
        () async {
      adapter.setupSuccess(_validSummaryJson(id: 'concurrent-result'));

      // Launch 5 calls concurrently.
      final futures = List.generate(
        5,
        (i) => service.summarizeText('This is concurrent call number $i test'),
      );

      final results = await Future.wait(futures);
      expect(results.length, 5);
      for (final result in results) {
        expect(result, isA<SummaryModel>());
        expect(result.id, 'concurrent-result');
      }
      expect(adapter.callCount, 5);
    });
  });

  // ---------------------------------------------------------------------------
  // DioException type mapping
  // ---------------------------------------------------------------------------

  group('DioException type mapping edge cases', () {
    test('should map sendTimeout to TimeoutException', () async {
      adapter.exceptionType = DioExceptionType.sendTimeout;

      expect(
        () => service.summarizeText(_validText),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('should map receiveTimeout to TimeoutException', () async {
      adapter.exceptionType = DioExceptionType.receiveTimeout;

      expect(
        () => service.summarizeText(_validText),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('should map unknown DioException to ApiException', () async {
      adapter.exceptionType = DioExceptionType.unknown;

      expect(
        () => service.summarizeText(_validText),
        throwsA(isA<ApiException>()),
      );
    });

    test('should handle bad response with non-Map body', () async {
      adapter.setupError(500, body: 'plain string error');

      try {
        await service.summarizeText(_validText);
        fail('Expected ApiException');
      } on ApiException catch (e) {
        expect(e.message, 'Server error'); // fallback message
        expect(e.statusCode, 500);
      }
    });
  });
}
