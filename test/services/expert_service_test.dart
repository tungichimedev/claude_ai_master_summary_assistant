import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/expert_service.dart';
import 'package:ai_master/models/expert_model.dart';
import 'package:ai_master/models/subscription_model.dart';
import 'package:ai_master/utils/exceptions.dart';

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

Map<String, dynamic> _expertMessageJson({
  String id = 'msg-1',
  String role = 'assistant',
  String content = 'Here is my expert advice.',
}) =>
    {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': '2026-01-15T12:00:00.000Z',
    };

// =============================================================================
// Tests
// =============================================================================

void main() {
  late Dio dio;
  late MockDioAdapter adapter;
  late ExpertService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://fake-api.example.com'));
    adapter = MockDioAdapter();
    dio.httpClientAdapter = adapter;
    service = ExpertService(dio: dio);
  });

  // ---------------------------------------------------------------------------
  // sendQuery
  // ---------------------------------------------------------------------------

  group('sendQuery', () {
    test('returns ExpertMessage on success', () async {
      adapter.setupSuccess(_expertMessageJson());

      final result = await service.sendQuery(
        ExpertType.fitness,
        'How do I build muscle?',
        [],
      );
      expect(result, isA<ExpertMessage>());
      expect(result.content, 'Here is my expert advice.');
      expect(result.role, MessageRole.assistant);
    });

    test('passes conversation history', () async {
      adapter.setupSuccess(_expertMessageJson(content: 'Follow up response'));

      final history = [
        ExpertMessage(
          id: 'prev-1',
          role: MessageRole.user,
          content: 'First question',
          timestamp: DateTime(2026, 1, 15),
        ),
        ExpertMessage(
          id: 'prev-2',
          role: MessageRole.assistant,
          content: 'First answer',
          timestamp: DateTime(2026, 1, 15),
        ),
      ];

      final result = await service.sendQuery(
        ExpertType.chef,
        'Follow up question',
        history,
      );
      expect(result.content, 'Follow up response');
    });

    test('throws ContentTooShortException on empty message', () {
      expect(
        () => service.sendQuery(ExpertType.fitness, '', []),
        throwsA(isA<ContentTooShortException>()),
      );
    });

    test('throws ContentTooShortException on whitespace-only message', () {
      expect(
        () => service.sendQuery(ExpertType.fitness, '   ', []),
        throwsA(isA<ContentTooShortException>()),
      );
    });

    test('throws ApiException on 500', () async {
      adapter.setupError(500, body: {'error': 'Server error'});

      expect(
        () => service.sendQuery(ExpertType.chef, 'A question', []),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws TokenBudgetExceededException on 429', () async {
      adapter.setupError(429);

      expect(
        () => service.sendQuery(ExpertType.chef, 'A question', []),
        throwsA(isA<TokenBudgetExceededException>()),
      );
    });

    test('throws NetworkException on connection error', () async {
      adapter.setupConnectionError();

      expect(
        () => service.sendQuery(ExpertType.chef, 'A question', []),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws TimeoutException on timeout', () async {
      adapter.setupTimeout();

      expect(
        () => service.sendQuery(ExpertType.chef, 'A question', []),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getAvailableExperts
  // ---------------------------------------------------------------------------

  group('getAvailableExperts', () {
    test('returns 6 experts total for any tier', () {
      final freeExperts = service.getAvailableExperts(SubscriptionTier.free);
      final proExperts = service.getAvailableExperts(SubscriptionTier.pro);

      expect(freeExperts.length, 6);
      expect(proExperts.length, 6);
    });

    test('free tier has 3 unlocked and 3 locked experts', () {
      final experts = service.getAvailableExperts(SubscriptionTier.free);
      final unlocked = experts.where((e) => !e.isLocked).toList();
      final locked = experts.where((e) => e.isLocked).toList();

      expect(unlocked.length, 3);
      expect(locked.length, 3);
    });

    test('free tier unlocked experts are socialMedia, fitness, writingAssistant',
        () {
      final experts = service.getAvailableExperts(SubscriptionTier.free);
      final unlockedTypes =
          experts.where((e) => !e.isLocked).map((e) => e.type).toSet();

      expect(unlockedTypes, contains(ExpertType.socialMedia));
      expect(unlockedTypes, contains(ExpertType.fitness));
      expect(unlockedTypes, contains(ExpertType.writingAssistant));
    });

    test('free tier locked experts are chef, homeAdvisor, salesCoach', () {
      final experts = service.getAvailableExperts(SubscriptionTier.free);
      final lockedTypes =
          experts.where((e) => e.isLocked).map((e) => e.type).toSet();

      expect(lockedTypes, contains(ExpertType.chef));
      expect(lockedTypes, contains(ExpertType.homeAdvisor));
      expect(lockedTypes, contains(ExpertType.salesCoach));
    });

    test('pro tier has all 6 experts unlocked', () {
      final experts = service.getAvailableExperts(SubscriptionTier.pro);
      final locked = experts.where((e) => e.isLocked);

      expect(locked, isEmpty);
    });

    test('every expert has a non-empty name', () {
      final experts = service.getAvailableExperts(SubscriptionTier.pro);
      for (final expert in experts) {
        expect(expert.name.isNotEmpty, true,
            reason: '${expert.type} should have a name');
      }
    });

    test('every expert has a non-empty description', () {
      final experts = service.getAvailableExperts(SubscriptionTier.pro);
      for (final expert in experts) {
        expect(expert.description.isNotEmpty, true,
            reason: '${expert.type} should have a description');
      }
    });

    test('every expert has a non-empty system prompt', () {
      final experts = service.getAvailableExperts(SubscriptionTier.pro);
      for (final expert in experts) {
        expect(expert.systemPrompt.isNotEmpty, true,
            reason: '${expert.type} should have a system prompt');
      }
    });

    test('every expert has gradient colors', () {
      final experts = service.getAvailableExperts(SubscriptionTier.pro);
      for (final expert in experts) {
        expect(expert.gradientColors.length, 2,
            reason: '${expert.type} should have 2 gradient colors');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // getSystemPrompt
  // ---------------------------------------------------------------------------

  group('getSystemPrompt', () {
    test('returns non-empty string for every ExpertType', () {
      for (final type in ExpertType.values) {
        final prompt = service.getSystemPrompt(type);
        expect(prompt.isNotEmpty, true,
            reason: '${type.name} should have a system prompt');
      }
    });

    test('socialMedia prompt mentions social media concepts', () {
      final prompt = service.getSystemPrompt(ExpertType.socialMedia);
      expect(prompt.toLowerCase().contains('social media'), true);
    });

    test('fitness prompt mentions workout or fitness', () {
      final prompt = service.getSystemPrompt(ExpertType.fitness);
      expect(
        prompt.toLowerCase().contains('fitness') ||
            prompt.toLowerCase().contains('workout'),
        true,
      );
    });

    test('chef prompt mentions recipe or cooking', () {
      final prompt = service.getSystemPrompt(ExpertType.chef);
      expect(
        prompt.toLowerCase().contains('recipe') ||
            prompt.toLowerCase().contains('cooking'),
        true,
      );
    });

    test('each expert type returns a distinct prompt', () {
      final prompts = ExpertType.values.map(service.getSystemPrompt).toSet();
      expect(prompts.length, ExpertType.values.length);
    });
  });
}
