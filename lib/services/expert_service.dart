import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/expert_model.dart';
import '../models/subscription_model.dart';
import '../utils/exceptions.dart';

/// Service for AI Expert chat interactions.
///
/// Pure Dart — depends on [Dio] for HTTP to Cloud Functions backend.
class ExpertService {
  final Dio _dio;

  ExpertService({required Dio dio}) : _dio = dio;

  // ---------------------------------------------------------------------------
  // System prompts for each expert persona
  // ---------------------------------------------------------------------------

  static const _systemPrompts = {
    ExpertType.socialMedia: '''You are an expert Social Media Strategist with deep knowledge of Instagram, TikTok, X (Twitter), LinkedIn, and YouTube. You provide:
- Content strategy and scheduling advice
- Caption and hashtag generation
- Engagement optimization tips
- Trend analysis and content ideas
- Platform-specific best practices

Always respond with structured, actionable advice. Use bullet points and numbered steps.''',
    ExpertType.fitness: '''You are an expert Fitness Coach and Certified Personal Trainer. You provide:
- Personalized workout plans based on goals (weight loss, muscle gain, flexibility)
- Exercise form guidance and alternatives
- Nutrition advice and meal planning
- Progress tracking recommendations
- Injury prevention tips

Always respond with structured workout cards including exercises, sets, reps, and rest times.''',
    ExpertType.chef: '''You are an expert Chef and Culinary Instructor. You provide:
- Recipe suggestions based on available ingredients
- Step-by-step cooking instructions
- Dietary restriction accommodations (vegan, keto, gluten-free, etc.)
- Meal prep and planning
- Cooking technique education

Always respond with structured recipes including ingredient lists and numbered steps.''',
    ExpertType.homeAdvisor: '''You are an expert Home & Life Improvement Advisor. You provide:
- DIY project guidance
- Home organization tips
- Budget-friendly improvement ideas
- Cleaning and maintenance schedules
- Smart home recommendations

Always respond with practical, step-by-step advice with estimated costs and time.''',
    ExpertType.salesCoach: '''You are an expert Sales & Customer Service Coach. You provide:
- Sales pitch preparation and role-play scenarios
- Objection handling scripts
- Customer service response templates
- Negotiation strategies
- CRM best practices

Always respond with structured scripts, templates, and actionable techniques.''',
    ExpertType.writingAssistant: '''You are an expert Writing & Research Assistant. You provide:
- Blog post and article drafting
- Research summarization and synthesis
- Grammar and style checking
- Citation and source suggestions
- Creative writing prompts and assistance

Always respond with well-structured, clear prose. Offer specific improvements.''',
  };

  /// Experts available on the free tier.
  static const _freeExperts = {
    ExpertType.socialMedia,
    ExpertType.fitness,
    ExpertType.writingAssistant,
  };

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Send a message to an AI expert and receive the full response.
  ///
  /// [history] is the conversation so far, used for context.
  Future<ExpertMessage> sendQuery(
    ExpertType expert,
    String message,
    List<ExpertMessage> history,
  ) async {
    if (message.trim().isEmpty) {
      throw const ContentTooShortException('Message cannot be empty.');
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/expert/query',
        data: {
          'expert': expert.name,
          'message': message,
          'systemPrompt': getSystemPrompt(expert),
          'history': history.map((m) => m.toJson()).toList(),
        },
      );
      if (response.data == null) {
        throw const ApiException('Empty response from expert service.');
      }
      return ExpertMessage.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Send a message with streaming response (SSE / chunked).
  Stream<String> sendQueryStream(
    ExpertType expert,
    String message,
    List<ExpertMessage> history,
  ) async* {
    if (message.trim().isEmpty) {
      throw const ContentTooShortException('Message cannot be empty.');
    }
    try {
      final response = await _dio.post<ResponseBody>(
        '/expert/query/stream',
        data: {
          'expert': expert.name,
          'message': message,
          'systemPrompt': getSystemPrompt(expert),
          'history': history.map((m) => m.toJson()).toList(),
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw const ApiException('No stream received from expert service.');
      }

      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        for (final line in text.split('\n')) {
          if (line.startsWith('data: ')) {
            final payload = line.substring(6).trim();
            if (payload == '[DONE]') return;
            yield payload;
          } else if (line.isNotEmpty && !line.startsWith(':')) {
            yield line;
          }
        }
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Expert catalogue
  // ---------------------------------------------------------------------------

  /// Return the list of experts available for the given [tier].
  ///
  /// Free users get 3 experts; all tiers above free get every expert.
  List<ExpertModel> getAvailableExperts(SubscriptionTier tier) {
    return ExpertType.values.map((type) {
      final isLocked =
          tier == SubscriptionTier.free && !_freeExperts.contains(type);
      return ExpertModel(
        type: type,
        name: _expertDisplayName(type),
        description: _expertDescription(type),
        iconEmoji: _expertIcon(type),
        gradientColors: _expertGradient(type),
        systemPrompt: getSystemPrompt(type),
        isLocked: isLocked,
      );
    }).toList();
  }

  /// Return the system prompt for the given [expert] type.
  String getSystemPrompt(ExpertType expert) {
    return _systemPrompts[expert] ?? _systemPrompts[ExpertType.writingAssistant]!;
  }

  // ---------------------------------------------------------------------------
  // Display metadata helpers
  // ---------------------------------------------------------------------------

  String _expertDisplayName(ExpertType type) {
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

  String _expertDescription(ExpertType type) {
    switch (type) {
      case ExpertType.socialMedia:
        return 'Content strategy, captions, hashtags & growth tips';
      case ExpertType.fitness:
        return 'Workout plans, nutrition advice & progress tracking';
      case ExpertType.chef:
        return 'Recipes, meal prep & cooking techniques';
      case ExpertType.homeAdvisor:
        return 'DIY projects, organization & smart home tips';
      case ExpertType.salesCoach:
        return 'Sales scripts, objection handling & negotiation';
      case ExpertType.writingAssistant:
        return 'Blog posts, research & grammar assistance';
    }
  }

  String _expertIcon(ExpertType type) {
    switch (type) {
      case ExpertType.socialMedia:
        return '📱';
      case ExpertType.fitness:
        return '💪';
      case ExpertType.chef:
        return '👨‍🍳';
      case ExpertType.homeAdvisor:
        return '🏠';
      case ExpertType.salesCoach:
        return '💼';
      case ExpertType.writingAssistant:
        return '✍️';
    }
  }

  List<int> _expertGradient(ExpertType type) {
    switch (type) {
      case ExpertType.socialMedia:
        return [0xFF6366F1, 0xFF8B5CF6]; // indigo -> violet
      case ExpertType.fitness:
        return [0xFFEF4444, 0xFFF97316]; // red -> orange
      case ExpertType.chef:
        return [0xFFF59E0B, 0xFFEF4444]; // amber -> red
      case ExpertType.homeAdvisor:
        return [0xFF10B981, 0xFF3B82F6]; // emerald -> blue
      case ExpertType.salesCoach:
        return [0xFF3B82F6, 0xFF6366F1]; // blue -> indigo
      case ExpertType.writingAssistant:
        return [0xFF8B5CF6, 0xFFEC4899]; // violet -> pink
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

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
