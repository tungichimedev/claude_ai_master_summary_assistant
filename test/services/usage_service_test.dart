import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/usage_service.dart';
import 'package:ai_master/models/subscription_model.dart';
import 'package:ai_master/models/usage_model.dart';
import 'package:ai_master/utils/exceptions.dart';

// =============================================================================
// Mock UsageCache (in-memory)
// =============================================================================

class MockUsageCache implements UsageCache {
  Map<String, dynamic>? _data;
  bool shouldThrow = false;

  @override
  Future<Map<String, dynamic>?> get() async {
    if (shouldThrow) throw Exception('Cache read error');
    return _data;
  }

  @override
  Future<void> put(Map<String, dynamic> data) async {
    if (shouldThrow) throw Exception('Cache write error');
    _data = Map<String, dynamic>.from(data);
  }

  @override
  Future<void> clear() async {
    if (shouldThrow) throw Exception('Cache clear error');
    _data = null;
  }
}

// =============================================================================
// Mock Dio Adapter
// =============================================================================

class MockDioAdapter implements HttpClientAdapter {
  int statusCode = 200;
  dynamic responseData;
  DioExceptionType? exceptionType;

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
      statusCode,
      headers: headers.map.map((k, v) => MapEntry(k, v)),
    );
  }

  String _toJson(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    if (value is String) return '"${value.replaceAll('"', '\\"')}"';
    if (value is List) return '[${value.map(_toJson).join(',')}]';
    if (value is Map) {
      final entries =
          value.entries.map((e) => '"${e.key}":${_toJson(e.value)}').join(',');
      return '{$entries}';
    }
    return '"$value"';
  }

  @override
  void close({bool force = false}) {}
}

// =============================================================================
// Test helpers
// =============================================================================

Map<String, dynamic> _usageJson({
  int summariesUsed = 0,
  int tokensUsed = 0,
  int expertQueriesUsed = 0,
  DateTime? lastResetDate,
  int dailyLimit = 3,
  int tokenLimit = 5000,
}) =>
    {
      'summariesUsed': summariesUsed,
      'tokensUsed': tokensUsed,
      'expertQueriesUsed': expertQueriesUsed,
      'lastResetDate':
          (lastResetDate ?? DateTime.now()).toIso8601String(),
      'dailyLimit': dailyLimit,
      'tokenLimit': tokenLimit,
    };

// =============================================================================
// Tests
// =============================================================================

void main() {
  late Dio dio;
  late MockDioAdapter adapter;
  late MockUsageCache cache;
  late UsageService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://fake-api.example.com'));
    adapter = MockDioAdapter();
    dio.httpClientAdapter = adapter;
    cache = MockUsageCache();
    service = UsageService(dio: dio, cache: cache);
  });

  // ---------------------------------------------------------------------------
  // getUsage
  // ---------------------------------------------------------------------------

  group('getUsage', () {
    test('returns cached usage when same day', () async {
      final today = DateTime.now();
      await cache.put(_usageJson(summariesUsed: 2, lastResetDate: today));

      // The adapter should NOT be called because cache is valid.
      adapter.setupSuccess(_usageJson(summariesUsed: 99));

      final usage = await service.getUsage();
      expect(usage.summariesUsed, 2); // from cache, not server
    });

    test('fetches from server when cache is empty', () async {
      adapter.setupSuccess(_usageJson(summariesUsed: 5));

      final usage = await service.getUsage();
      expect(usage.summariesUsed, 5);
    });

    test('fetches from server when cache is stale (different day)', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await cache.put(_usageJson(summariesUsed: 2, lastResetDate: yesterday));
      adapter.setupSuccess(_usageJson(summariesUsed: 0));

      final usage = await service.getUsage();
      expect(usage.summariesUsed, 0); // fresh from server
    });

    test('returns correct UsageModel fields', () async {
      adapter.setupSuccess(_usageJson(
        summariesUsed: 2,
        tokensUsed: 1500,
        expertQueriesUsed: 1,
        dailyLimit: 3,
        tokenLimit: 5000,
      ));

      final usage = await service.getUsage();
      expect(usage.summariesUsed, 2);
      expect(usage.tokensUsed, 1500);
      expect(usage.expertQueriesUsed, 1);
      expect(usage.dailyLimit, 3);
      expect(usage.tokenLimit, 5000);
    });

    test('throws ApiException on server error', () async {
      adapter.setupError(500, body: {'error': 'Internal error'});

      expect(() => service.getUsage(), throwsA(isA<ApiException>()));
    });

    test('caches response from server', () async {
      adapter.setupSuccess(_usageJson(summariesUsed: 3));

      await service.getUsage();
      final cached = await cache.get();
      expect(cached, isNotNull);
      expect(cached!['summariesUsed'], 3);
    });
  });

  // ---------------------------------------------------------------------------
  // incrementSummaryCount
  // ---------------------------------------------------------------------------

  group('incrementSummaryCount', () {
    test('updates cache after successful increment', () async {
      adapter.setupSuccess(_usageJson(summariesUsed: 4));

      await service.incrementSummaryCount();
      final cached = await cache.get();
      expect(cached, isNotNull);
      expect(cached!['summariesUsed'], 4);
    });

    test('throws TokenBudgetExceededException on 429', () async {
      adapter.setupError(429);

      expect(
        () => service.incrementSummaryCount(),
        throwsA(isA<TokenBudgetExceededException>()),
      );
    });

    test('throws NetworkException on connection error', () async {
      adapter.setupConnectionError();

      expect(
        () => service.incrementSummaryCount(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws ApiException on 500', () async {
      adapter.setupError(500);

      expect(
        () => service.incrementSummaryCount(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // incrementTokenCount
  // ---------------------------------------------------------------------------

  group('incrementTokenCount', () {
    test('does nothing for zero or negative tokens', () async {
      // Should return immediately without calling API.
      adapter.setupError(500); // would throw if called
      await service.incrementTokenCount(0);
      await service.incrementTokenCount(-5);
      // No exception means the adapter was never hit.
    });

    test('updates cache on success', () async {
      adapter.setupSuccess(_usageJson(tokensUsed: 2000));

      await service.incrementTokenCount(500);
      final cached = await cache.get();
      expect(cached!['tokensUsed'], 2000);
    });

    test('throws on server error', () async {
      adapter.setupError(500);
      expect(
        () => service.incrementTokenCount(100),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // canSummarize
  // ---------------------------------------------------------------------------

  group('canSummarize', () {
    test('returns true when under free tier limit', () async {
      await cache.put(_usageJson(
        summariesUsed: 1,
        tokensUsed: 1000,
        lastResetDate: DateTime.now(),
      ));

      final can = await service.canSummarize(SubscriptionTier.free);
      expect(can, true);
    });

    test('returns false when at free tier summary limit', () async {
      await cache.put(_usageJson(
        summariesUsed: 3, // free limit = 3
        tokensUsed: 1000,
        lastResetDate: DateTime.now(),
      ));

      final can = await service.canSummarize(SubscriptionTier.free);
      expect(can, false);
    });

    test('returns false when at free tier token limit', () async {
      await cache.put(_usageJson(
        summariesUsed: 1,
        tokensUsed: 5000, // free token limit = 5000
        lastResetDate: DateTime.now(),
      ));

      final can = await service.canSummarize(SubscriptionTier.free);
      expect(can, false);
    });

    test('returns true for pro tier (unlimited)', () async {
      await cache.put(_usageJson(
        summariesUsed: 100,
        tokensUsed: 150000,
        lastResetDate: DateTime.now(),
      ));

      final can = await service.canSummarize(SubscriptionTier.pro);
      expect(can, true);
    });

    test('returns true when exactly one under free limit', () async {
      await cache.put(_usageJson(
        summariesUsed: 2,
        tokensUsed: 4999,
        lastResetDate: DateTime.now(),
      ));

      final can = await service.canSummarize(SubscriptionTier.free);
      expect(can, true);
    });
  });

  // ---------------------------------------------------------------------------
  // remainingSummaries
  // ---------------------------------------------------------------------------

  group('remainingSummaries', () {
    test('returns correct remaining for free tier', () async {
      await cache.put(_usageJson(
        summariesUsed: 1,
        lastResetDate: DateTime.now(),
      ));

      final remaining =
          await service.remainingSummaries(SubscriptionTier.free);
      expect(remaining, 2); // limit=3, used=1
    });

    test('returns 0 when at limit', () async {
      await cache.put(_usageJson(
        summariesUsed: 3,
        lastResetDate: DateTime.now(),
      ));

      final remaining =
          await service.remainingSummaries(SubscriptionTier.free);
      expect(remaining, 0);
    });

    test('returns 0 when over limit (clamped)', () async {
      await cache.put(_usageJson(
        summariesUsed: 5,
        lastResetDate: DateTime.now(),
      ));

      final remaining =
          await service.remainingSummaries(SubscriptionTier.free);
      expect(remaining, 0);
    });

    test('returns 999 for pro tier (effectively unlimited)', () async {
      await cache.put(_usageJson(
        summariesUsed: 50,
        lastResetDate: DateTime.now(),
      ));

      final remaining =
          await service.remainingSummaries(SubscriptionTier.pro);
      expect(remaining, 999);
    });

    test('returns full limit when nothing used', () async {
      await cache.put(_usageJson(
        summariesUsed: 0,
        lastResetDate: DateTime.now(),
      ));

      final remaining =
          await service.remainingSummaries(SubscriptionTier.free);
      expect(remaining, 3);
    });
  });
}
