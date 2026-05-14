/// Custom exception hierarchy for AI Master.
///
/// All service-layer errors are mapped to one of these domain exceptions
/// so controllers and UI never depend on third-party error types.

// ---------------------------------------------------------------------------
// Base
// ---------------------------------------------------------------------------

/// Root class for all domain-specific exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => '$runtimeType: $message';
}

// ---------------------------------------------------------------------------
// Network / HTTP
// ---------------------------------------------------------------------------

/// Thrown when a network request fails due to connectivity issues.
class NetworkException extends AppException {
  const NetworkException([
    String message = 'No internet connection. Please check your network.',
  ]) : super(message);
}

/// Thrown when the backend returns an unexpected status code or body.
class ApiException extends AppException {
  final int? statusCode;

  const ApiException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
  });

  @override
  String toString() =>
      'ApiException($statusCode): $message';
}

/// Thrown when a request times out before receiving a response.
class TimeoutException extends AppException {
  const TimeoutException([
    String message = 'Request timed out. Please try again.',
  ]) : super(message);
}

// ---------------------------------------------------------------------------
// AI / Summarisation
// ---------------------------------------------------------------------------

/// Thrown when the user's token budget for the current billing period is
/// exhausted.
class TokenBudgetExceededException extends AppException {
  const TokenBudgetExceededException([
    String message = 'You have used all your tokens for today. '
        'Upgrade your plan or try again tomorrow.',
  ]) : super(message);
}

/// Thrown when the submitted content exceeds the tier's maximum input size.
class ContentTooLongException extends AppException {
  final int maxWords;
  final int actualWords;

  const ContentTooLongException({
    required this.maxWords,
    required this.actualWords,
    String message = 'Content exceeds the maximum allowed length.',
  }) : super(message);

  @override
  String toString() =>
      'ContentTooLongException: $message (max: $maxWords, actual: $actualWords)';
}

/// Thrown when the content is empty or too short to produce a useful summary.
class ContentTooShortException extends AppException {
  const ContentTooShortException([
    String message = 'Content is too short to summarize. '
        'Please provide at least a few sentences.',
  ]) : super(message);
}

/// Thrown when the server-side content extractor cannot parse a URL.
class UrlParsingException extends AppException {
  final String url;

  const UrlParsingException({
    required this.url,
    String message = 'Could not extract content from the provided URL.',
  }) : super(message);
}

/// Thrown when the server-side PDF extractor fails.
class PdfParsingException extends AppException {
  const PdfParsingException([
    String message = 'Could not extract text from the uploaded PDF.',
  ]) : super(message);
}

// ---------------------------------------------------------------------------
// Authentication
// ---------------------------------------------------------------------------

/// Thrown when a Firebase Auth operation fails.
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Thrown when an operation requires authentication but the user is not
/// signed in.
class UnauthenticatedException extends AppException {
  const UnauthenticatedException([
    String message = 'You must be signed in to perform this action.',
  ]) : super(message);
}

// ---------------------------------------------------------------------------
// Subscription / Purchase
// ---------------------------------------------------------------------------

/// Thrown when a RevenueCat purchase operation fails.
class PurchaseException extends AppException {
  const PurchaseException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Thrown when the user has already purchased and tries to purchase again.
class PurchaseAlreadyActiveException extends AppException {
  const PurchaseAlreadyActiveException([
    String message = 'You already have an active subscription.',
  ]) : super(message);
}

/// Thrown when the user cancels the purchase flow.
class PurchaseCancelledException extends AppException {
  const PurchaseCancelledException([
    String message = 'Purchase was cancelled.',
  ]) : super(message);
}

// ---------------------------------------------------------------------------
// Usage / Limits
// ---------------------------------------------------------------------------

/// Thrown when the user has reached their daily summary limit.
class DailyLimitReachedException extends AppException {
  final int limit;

  const DailyLimitReachedException({
    required this.limit,
    String message = 'You have reached your daily summary limit.',
  }) : super(message);
}

/// Thrown when the free-tier offline library is full.
class LibraryFullException extends AppException {
  final int maxItems;

  const LibraryFullException({
    required this.maxItems,
    String message = 'Your library is full. Upgrade to save more summaries.',
  }) : super(message);
}

// ---------------------------------------------------------------------------
// Storage
// ---------------------------------------------------------------------------

/// Thrown when a local database (Isar) operation fails.
class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.originalError,
  });
}

// ---------------------------------------------------------------------------
// Generic / Fallback
// ---------------------------------------------------------------------------

/// Catch-all for unexpected errors that don't fit other categories.
class UnexpectedException extends AppException {
  const UnexpectedException([
    String message = 'An unexpected error occurred. Please try again.',
    dynamic originalError,
  ]) : super(message, originalError: originalError);
}
