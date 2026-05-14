import 'dart:async';

import '../models/user_model.dart';
import '../utils/exceptions.dart';

/// Abstract interface for Firebase Auth so the service stays pure Dart and
/// testable without pulling in the Flutter Firebase SDK.
abstract class AuthProvider {
  /// Sign in anonymously.
  Future<Map<String, dynamic>> signInAnonymously();

  /// Sign in with email and password.
  Future<Map<String, dynamic>> signInWithEmail(String email, String password);

  /// Create a new account with email, password, and display name.
  Future<Map<String, dynamic>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );

  /// Sign in via Google One-Tap / OAuth.
  Future<Map<String, dynamic>> signInWithGoogle();

  /// Link anonymous account to email credentials.
  Future<Map<String, dynamic>> linkAnonymousToEmail(
    String email,
    String password,
  );

  /// Link anonymous account to Google credentials.
  Future<Map<String, dynamic>> linkAnonymousToGoogle();

  /// Sign out the current user.
  Future<void> signOut();

  /// Returns the current user's data map, or null if signed out.
  Map<String, dynamic>? get currentUserData;

  /// Stream of auth state changes (null when signed out).
  Stream<Map<String, dynamic>?> get authStateChanges;
}

/// Service for authentication operations.
///
/// Pure Dart — depends on [AuthProvider] abstraction (implemented by a
/// Firebase-specific adapter injected via providers).
class AuthService {
  final AuthProvider _provider;

  AuthService({required AuthProvider provider}) : _provider = provider;

  // ---------------------------------------------------------------------------
  // Sign-in methods
  // ---------------------------------------------------------------------------

  /// Create or retrieve an anonymous user session.
  Future<UserModel> signInAnonymously() async {
    try {
      final data = await _provider.signInAnonymously();
      return UserModel.fromJson(data);
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Sign in with email and password.
  Future<UserModel> signInWithEmail(String email, String password) async {
    _validateEmail(email);
    _validatePassword(password);
    try {
      final data = await _provider.signInWithEmail(email, password);
      return UserModel.fromJson(data);
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Register a new account with email, password, and display name.
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _validateEmail(email);
    _validatePassword(password);
    if (displayName.trim().isEmpty) {
      throw const AuthException('Display name cannot be empty.',
          code: 'invalid-display-name');
    }
    try {
      final data =
          await _provider.signUpWithEmail(email, password, displayName);
      return UserModel.fromJson(data);
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Sign in with Google OAuth.
  Future<UserModel> signInWithGoogle() async {
    try {
      final data = await _provider.signInWithGoogle();
      return UserModel.fromJson(data);
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Account linking (upgrade anonymous -> permanent)
  // ---------------------------------------------------------------------------

  /// Link an anonymous account to email credentials.
  Future<UserModel> linkAnonymousToEmail(String email, String password) async {
    _validateEmail(email);
    _validatePassword(password);
    try {
      final data = await _provider.linkAnonymousToEmail(email, password);
      return UserModel.fromJson(data);
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Link an anonymous account to Google credentials.
  Future<UserModel> linkAnonymousToGoogle() async {
    try {
      final data = await _provider.linkAnonymousToGoogle();
      return UserModel.fromJson(data);
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _provider.signOut();
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Returns the currently authenticated user, or null.
  UserModel? get currentUser {
    final data = _provider.currentUserData;
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  /// Stream of user authentication state changes.
  Stream<UserModel?> get authStateChanges {
    return _provider.authStateChanges.map(
      (data) => data == null ? null : UserModel.fromJson(data),
    );
  }

  // ---------------------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------------------

  void _validateEmail(String email) {
    if (email.trim().isEmpty) {
      throw const AuthException('Email cannot be empty.', code: 'invalid-email');
    }
    // Simple regex — the server validates fully.
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw const AuthException('Please enter a valid email address.',
          code: 'invalid-email');
    }
  }

  void _validatePassword(String password) {
    if (password.length < 6) {
      throw const AuthException(
        'Password must be at least 6 characters.',
        code: 'weak-password',
      );
    }
  }

  /// Map platform auth errors to domain [AuthException].
  AppException _mapAuthError(dynamic error) {
    if (error is AppException) return error;

    final message = error.toString();

    // Common Firebase Auth error codes.
    if (message.contains('user-not-found') ||
        message.contains('wrong-password')) {
      return const AuthException(
        'Invalid email or password.',
        code: 'invalid-credentials',
      );
    }
    if (message.contains('email-already-in-use')) {
      return const AuthException(
        'An account with this email already exists.',
        code: 'email-already-in-use',
      );
    }
    if (message.contains('too-many-requests')) {
      return const AuthException(
        'Too many attempts. Please try again later.',
        code: 'too-many-requests',
      );
    }
    if (message.contains('network-request-failed') ||
        message.contains('network')) {
      return const NetworkException();
    }

    return AuthException(
      'Authentication failed. Please try again.',
      originalError: error,
    );
  }
}
