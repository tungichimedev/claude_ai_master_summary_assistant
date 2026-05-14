import 'dart:async';

import 'package:ai_master/controllers/auth_controller.dart';
import 'package:ai_master/controllers/providers.dart';
import 'package:ai_master/models/user_model.dart';
import 'package:ai_master/utils/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_services.dart';
import '../helpers/test_factories.dart';

/// Pumps the event queue to allow microtasks and stream callbacks to complete.
Future<void> pumpEventQueue({int times = 50}) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late MockAuthProvider mockAuthProvider;
  late ProviderContainer container;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    container = ProviderContainer(overrides: [
      authProviderAdapter.overrideWithValue(mockAuthProvider),
    ]);
    // Keep a listener alive to prevent auto-dispose.
    container.listen(
      authControllerProvider,
      (prev, next) {},
      fireImmediately: true,
    );
  });

  tearDown(() {
    mockAuthProvider.dispose();
    container.dispose();
  });

  AuthController notifier() {
    return container.read(authControllerProvider.notifier);
  }

  group('AuthController', () {
    test('build() returns current user (null when not signed in)', () async {
      mockAuthProvider.reset();
      final user = await container.read(authControllerProvider.future);
      expect(user, isNull);
    });

    test('build() returns current user when already signed in', () async {
      // Dispose and recreate with a provider that has current user data.
      container.dispose();
      mockAuthProvider.dispose();
      mockAuthProvider = MockAuthProvider();
      final userData = TestFactories.createUserJson();
      mockAuthProvider.emitAuthState(userData);

      container = ProviderContainer(overrides: [
        authProviderAdapter.overrideWithValue(mockAuthProvider),
      ]);
      container.listen(
        authControllerProvider,
        (prev, next) {},
        fireImmediately: true,
      );

      final user = await container.read(authControllerProvider.future);
      expect(user, isNotNull);
      expect(user!.email, equals('test@example.com'));
    });

    test('signInAnonymously updates state with user', () async {
      await container.read(authControllerProvider.future);
      mockAuthProvider.userDataToReturn =
          TestFactories.createUserJson(isAnonymous: true);

      await notifier().signInAnonymously();

      final state = container.read(authControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNotNull);
      expect(mockAuthProvider.callLog, contains('signInAnonymously'));
    });

    test('signInWithEmail - success updates state with UserModel', () async {
      await container.read(authControllerProvider.future);
      mockAuthProvider.userDataToReturn =
          TestFactories.createUserJson(email: 'user@test.com');

      await notifier().signInWithEmail('user@test.com', 'password123');

      final state = container.read(authControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNotNull);
      expect(state.value!.email, equals('user@test.com'));
    });

    test('signInWithEmail - wrong password yields error state', () async {
      await container.read(authControllerProvider.future);
      mockAuthProvider.shouldThrow = true;
      mockAuthProvider.errorToThrow =
          Exception('wrong-password: Invalid credentials');

      await notifier().signInWithEmail('user@test.com', 'wrongpass');

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
    });

    test('signUpWithEmail - success updates state', () async {
      await container.read(authControllerProvider.future);
      mockAuthProvider.userDataToReturn =
          TestFactories.createUserJson(email: 'new@test.com');

      await notifier().signUpWithEmail('new@test.com', 'password123', 'New User');

      final state = container.read(authControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNotNull);
    });

    test('signUpWithEmail - error yields error state', () async {
      await container.read(authControllerProvider.future);
      mockAuthProvider.shouldThrow = true;
      mockAuthProvider.errorToThrow = Exception('email-already-in-use');

      await notifier().signUpWithEmail('existing@test.com', 'password123', 'User');

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
    });

    test('signOut sets state to null', () async {
      await container.read(authControllerProvider.future);

      await notifier().signInAnonymously();
      expect(container.read(authControllerProvider).value, isNotNull);

      await notifier().signOut();

      final state = container.read(authControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNull);
    });

    test('signInWithGoogle - success updates state', () async {
      await container.read(authControllerProvider.future);
      mockAuthProvider.userDataToReturn = TestFactories.createUserJson(
        email: 'google@test.com',
      );

      await notifier().signInWithGoogle();

      final state = container.read(authControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNotNull);
      expect(mockAuthProvider.callLog, contains('signInWithGoogle'));
    });

    test('signInWithGoogle - error yields error state', () async {
      await container.read(authControllerProvider.future);
      mockAuthProvider.shouldThrow = true;
      mockAuthProvider.errorToThrow = Exception('network-request-failed');

      await notifier().signInWithGoogle();

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
    });

    test('error recovery - after error, can sign in again', () async {
      await container.read(authControllerProvider.future);

      // First: fail.
      mockAuthProvider.shouldThrow = true;
      mockAuthProvider.errorToThrow = Exception('network error');
      await notifier().signInWithEmail('user@test.com', 'password123');
      expect(container.read(authControllerProvider).hasError, isTrue);

      // Second: succeed.
      mockAuthProvider.shouldThrow = false;
      mockAuthProvider.userDataToReturn =
          TestFactories.createUserJson(email: 'user@test.com');
      await notifier().signInWithEmail('user@test.com', 'password123');

      final state = container.read(authControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNotNull);
    });

    test('auth state changes stream updates controller state', () async {
      await container.read(authControllerProvider.future);

      // Simulate an external auth state change.
      final userData = TestFactories.createUserJson(email: 'stream@test.com');
      mockAuthProvider.emitAuthState(userData);

      // Need many pumps for broadcast stream -> mapped stream -> listener.
      await pumpEventQueue(times: 100);

      final state = container.read(authControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNotNull);
      expect(state.value!.email, equals('stream@test.com'));
    });

    test('signOut error yields error state', () async {
      await container.read(authControllerProvider.future);
      await notifier().signInAnonymously();

      mockAuthProvider.shouldThrow = true;
      mockAuthProvider.errorToThrow = Exception('Sign out failed');

      await notifier().signOut();

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
    });
  });
}
