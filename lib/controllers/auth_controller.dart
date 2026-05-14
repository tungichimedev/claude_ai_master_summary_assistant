import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../utils/exceptions.dart';
import 'providers.dart';

/// Controller that wraps [AuthService] and exposes authentication state to
/// the UI as an [AsyncValue<UserModel?>].
class AuthController extends AutoDisposeAsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final service = ref.read(authServiceProvider);

    // Listen to auth state changes and update our state.
    final sub = service.authStateChanges.listen((user) {
      state = AsyncData(user);
    });

    // Cancel the subscription when the provider is disposed.
    ref.onDispose(sub.cancel);

    // Return the current user synchronously if already signed in.
    return service.currentUser;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Sign in anonymously (silent, no UI needed).
  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(authServiceProvider);
      final user = await service.signInAnonymously();
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(
        e is AppException ? e : UnexpectedException(e.toString(), e),
        StackTrace.current,
      );
    }
  }

  /// Sign in with email and password.
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(authServiceProvider);
      final user = await service.signInWithEmail(email, password);
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(
        e is AppException ? e : UnexpectedException(e.toString(), e),
        StackTrace.current,
      );
    }
  }

  /// Create a new account with email, password, and display name.
  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(authServiceProvider);
      final user = await service.signUpWithEmail(email, password, name);
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(
        e is AppException ? e : UnexpectedException(e.toString(), e),
        StackTrace.current,
      );
    }
  }

  /// Sign in with Google OAuth.
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(authServiceProvider);
      final user = await service.signInWithGoogle();
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(
        e is AppException ? e : UnexpectedException(e.toString(), e),
        StackTrace.current,
      );
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      final service = ref.read(authServiceProvider);
      await service.signOut();
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(
        e is AppException ? e : UnexpectedException(e.toString(), e),
        StackTrace.current,
      );
    }
  }
}
