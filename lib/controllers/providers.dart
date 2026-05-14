import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/clipboard_service.dart';
import '../services/expert_service.dart';
import '../services/library_service.dart';
import '../services/streak_service.dart';
import '../services/subscription_service.dart';
import '../services/summarizer_service.dart';
import '../services/usage_service.dart';
import 'auth_controller.dart';
import 'expert_controller.dart';
import 'home_controller.dart';
import 'library_controller.dart';
import 'states.dart';
import 'subscription_controller.dart';
import 'summarizer_controller.dart';

// =============================================================================
// Configuration
// =============================================================================

/// Base URL for the Cloud Functions API.
///
/// Override this provider in tests or for different environments (dev / prod).
final apiBaseUrlProvider = Provider<String>(
  (ref) => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://us-central1-ai-master-app.cloudfunctions.net/api',
  ),
);

/// RevenueCat API key.
final revenueCatApiKeyProvider = Provider<String>(
  (ref) => const String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: '',
  ),
);

// =============================================================================
// HTTP Client
// =============================================================================

/// Shared [Dio] instance configured with base URL and auth interceptor.
final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Interceptor to attach the Firebase ID token to every request.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;
      if (user != null) {
        // The actual token retrieval would call Firebase Auth's getIdToken().
        // The AuthProvider adapter should expose this. For now we set the UID.
        options.headers['X-User-Id'] = user.uid;
      }
      handler.next(options);
    },
    onError: (error, handler) {
      handler.next(error);
    },
  ));

  return dio;
});

// =============================================================================
// Abstractions (override these in tests / platform layer)
// =============================================================================

/// Override with your Firebase Auth adapter.
final authProviderAdapter = Provider<AuthProvider>(
  (ref) => throw UnimplementedError(
    'authProviderAdapter must be overridden with a platform-specific '
    'AuthProvider implementation (e.g. FirebaseAuthProvider).',
  ),
);

/// Override with your RevenueCat adapter.
final purchaseProviderAdapter = Provider<PurchaseProvider>(
  (ref) => throw UnimplementedError(
    'purchaseProviderAdapter must be overridden with a platform-specific '
    'PurchaseProvider implementation (e.g. RevenueCatProvider).',
  ),
);

/// Override with your Isar-backed library storage.
final libraryStorageAdapter = Provider<LibraryStorage>(
  (ref) => throw UnimplementedError(
    'libraryStorageAdapter must be overridden with a concrete '
    'LibraryStorage implementation (e.g. IsarLibraryStorage).',
  ),
);

/// Override with your local usage cache (SharedPreferences, Isar, etc.).
final usageCacheAdapter = Provider<UsageCache>(
  (ref) => throw UnimplementedError(
    'usageCacheAdapter must be overridden with a concrete '
    'UsageCache implementation.',
  ),
);

/// Override with your streak storage (SharedPreferences or Isar).
final streakStorageAdapter = Provider<StreakStorage>(
  (ref) => throw UnimplementedError(
    'streakStorageAdapter must be overridden with a concrete '
    'StreakStorage implementation.',
  ),
);

/// Override with your clipboard platform adapter.
final clipboardProviderAdapter = Provider<ClipboardProvider>(
  (ref) => throw UnimplementedError(
    'clipboardProviderAdapter must be overridden with a platform-specific '
    'ClipboardProvider implementation.',
  ),
);

// =============================================================================
// Service Providers
// =============================================================================

/// Provides [SummarizerService] — HTTP-based summarisation.
final summarizerServiceProvider = Provider<SummarizerService>((ref) {
  return SummarizerService(dio: ref.watch(dioProvider));
});

/// Provides [LibraryService] — offline summary library (Isar).
final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService(storage: ref.watch(libraryStorageAdapter));
});

/// Provides [AuthService] — Firebase Authentication.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(provider: ref.watch(authProviderAdapter));
});

/// Provides [SubscriptionService] — RevenueCat subscriptions.
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(provider: ref.watch(purchaseProviderAdapter));
});

/// Provides [UsageService] — server-side usage tracking with local cache.
final usageServiceProvider = Provider<UsageService>((ref) {
  return UsageService(
    dio: ref.watch(dioProvider),
    cache: ref.watch(usageCacheAdapter),
  );
});

/// Provides [ExpertService] — AI expert chat.
final expertServiceProvider = Provider<ExpertService>((ref) {
  return ExpertService(dio: ref.watch(dioProvider));
});

/// Provides [StreakService] — daily streak tracking.
final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService(storage: ref.watch(streakStorageAdapter));
});

/// Provides [ClipboardService] — clipboard URL/text detection.
final clipboardServiceProvider = Provider<ClipboardService>((ref) {
  return ClipboardService(provider: ref.watch(clipboardProviderAdapter));
});

// =============================================================================
// Controller Providers (AsyncNotifier)
// =============================================================================

/// Provides [SummarizerController].
final summarizerControllerProvider =
    AsyncNotifierProvider.autoDispose<SummarizerController, SummaryState>(
  SummarizerController.new,
);

/// Provides [AuthController].
final authControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthController, UserModel?>(
  AuthController.new,
);

/// Provides [HomeController].
final homeControllerProvider =
    AsyncNotifierProvider.autoDispose<HomeController, HomeState>(
  HomeController.new,
);

/// Provides [LibraryController].
final libraryControllerProvider =
    AsyncNotifierProvider.autoDispose<LibraryController, LibraryState>(
  LibraryController.new,
);

/// Provides [SubscriptionController].
final subscriptionControllerProvider =
    AsyncNotifierProvider.autoDispose<SubscriptionController, SubscriptionModel>(
  SubscriptionController.new,
);

/// Provides [ExpertController].
final expertControllerProvider =
    AsyncNotifierProvider.autoDispose<ExpertController, ExpertChatState>(
  ExpertController.new,
);
