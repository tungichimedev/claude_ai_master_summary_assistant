import 'dart:async';

import 'package:dio/dio.dart';

import '../models/subscription_model.dart';
import '../models/usage_model.dart';
import '../utils/exceptions.dart';
import '../utils/tier_limits.dart';

/// Abstract interface for a local cache of usage data.
///
/// Allows quick reads without hitting the network on every check.
abstract class UsageCache {
  Future<Map<String, dynamic>?> get();
  Future<void> put(Map<String, dynamic> data);
  Future<void> clear();
}

/// Service for tracking and enforcing per-user usage limits.
///
/// Server-side is the source of truth; this service maintains a local cache
/// for fast reads and syncs with the backend on writes.
class UsageService {
  final Dio _dio;
  final UsageCache _cache;

  UsageService({required Dio dio, required UsageCache cache})
      : _dio = dio,
        _cache = cache;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Fetch the current usage, preferring the local cache.
  ///
  /// If the cache is empty or stale (different day), fetches from the server.
  Future<UsageModel> getUsage() async {
    // Try cache first.
    final cached = await _cache.get();
    if (cached != null) {
      final model = UsageModel.fromJson(cached);
      if (_isSameDay(model.lastResetDate, DateTime.now())) {
        return model;
      }
    }
    // Fetch fresh from backend.
    return _fetchAndCache();
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Increment the summary count on the server and update the local cache.
  Future<void> incrementSummaryCount() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/usage/increment-summary',
      );
      if (response.data != null) {
        await _cache.put(response.data!);
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Increment the token count by [tokens] on the server and update cache.
  Future<void> incrementTokenCount(int tokens) async {
    if (tokens <= 0) return;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/usage/increment-tokens',
        data: {'tokens': tokens},
      );
      if (response.data != null) {
        await _cache.put(response.data!);
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Limit checks
  // ---------------------------------------------------------------------------

  /// Whether the user can still create a summary given their [tier].
  ///
  /// Checks both daily summary count and token budget.
  Future<bool> canSummarize(SubscriptionTier tier) async {
    final usage = await getUsage();
    final summaryLimit = tier.dailySummaryLimit;
    final tokenLimit = tier.dailyTokenLimit;

    // Unlimited tiers.
    if (summaryLimit == -1) return true;

    if (usage.summariesUsed >= summaryLimit) return false;
    if (usage.tokensUsed >= tokenLimit) return false;
    return true;
  }

  /// Number of summaries the user can still create today.
  Future<int> remainingSummaries(SubscriptionTier tier) async {
    final usage = await getUsage();
    final limit = tier.dailySummaryLimit;
    if (limit == -1) return 999; // effectively unlimited
    return (limit - usage.summariesUsed).clamp(0, limit);
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<UsageModel> _fetchAndCache() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/usage');
      if (response.data == null) {
        throw const ApiException('Empty usage response from server.');
      }
      await _cache.put(response.data!);
      return UsageModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
        return ApiException(message, statusCode: status, originalError: e);
      default:
        return ApiException(
          e.message ?? 'Unexpected error.',
          originalError: e,
        );
    }
  }
}
