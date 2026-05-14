import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/auth_service.dart';
import 'package:ai_master/models/user_model.dart';
import 'package:ai_master/utils/exceptions.dart';

// =============================================================================
// Mock AuthProvider
// =============================================================================

class MockAuthProvider implements AuthProvider {
  Map<String, dynamic>? _currentUser;
  final StreamController<Map<String, dynamic>?> _authStreamController =
      StreamController<Map<String, dynamic>?>.broadcast();

  /// Pre-registered accounts for signIn testing: email -> {json, password}.
  final Map<String, _MockAccount> _accounts = {};

  /// Configure a pre-existing account.
  void addAccount(String email, String password, Map<String, dynamic> json) {
    _accounts[email] = _MockAccount(password: password, json: json);
  }

  /// If set, the next call will throw with this error message.
  String? nextError;

  void _checkError() {
    if (nextError != null) {
      final msg = nextError!;
      nextError = null;
      throw Exception(msg);
    }
  }

  @override
  Future<Map<String, dynamic>> signInAnonymously() async {
    _checkError();
    final json = {
      'uid': 'anon-uid-123',
      'isAnonymous': true,
      'referralCode': 'ANON123',
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
    };
    _currentUser = json;
    _authStreamController.add(json);
    return json;
  }

  @override
  Future<Map<String, dynamic>> signInWithEmail(
      String email, String password) async {
    _checkError();
    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw Exception('wrong-password');
    }
    _currentUser = account.json;
    _authStreamController.add(account.json);
    return account.json;
  }

  @override
  Future<Map<String, dynamic>> signUpWithEmail(
      String email, String password, String displayName) async {
    _checkError();
    if (_accounts.containsKey(email)) {
      throw Exception('email-already-in-use');
    }
    final json = {
      'uid': 'new-uid-456',
      'email': email,
      'displayName': displayName,
      'isAnonymous': false,
      'referralCode': 'NEW456',
      'createdAt': DateTime.now().toIso8601String(),
    };
    _accounts[email] = _MockAccount(password: password, json: json);
    _currentUser = json;
    _authStreamController.add(json);
    return json;
  }

  @override
  Future<Map<String, dynamic>> signInWithGoogle() async {
    _checkError();
    final json = {
      'uid': 'google-uid-789',
      'email': 'google@example.com',
      'displayName': 'Google User',
      'isAnonymous': false,
      'referralCode': 'GOOGLE789',
      'createdAt': DateTime.now().toIso8601String(),
    };
    _currentUser = json;
    _authStreamController.add(json);
    return json;
  }

  @override
  Future<Map<String, dynamic>> linkAnonymousToEmail(
      String email, String password) async {
    _checkError();
    // Preserve the current anonymous uid.
    final uid = _currentUser?['uid'] ?? 'anon-uid-123';
    final json = {
      'uid': uid,
      'email': email,
      'isAnonymous': false,
      'referralCode': _currentUser?['referralCode'] ?? 'REF',
      'createdAt': _currentUser?['createdAt'] ?? DateTime.now().toIso8601String(),
    };
    _currentUser = json;
    _authStreamController.add(json);
    return json;
  }

  @override
  Future<Map<String, dynamic>> linkAnonymousToGoogle() async {
    _checkError();
    final uid = _currentUser?['uid'] ?? 'anon-uid-123';
    final json = {
      'uid': uid,
      'email': 'google@example.com',
      'displayName': 'Google User',
      'isAnonymous': false,
      'referralCode': _currentUser?['referralCode'] ?? 'REF',
      'createdAt': _currentUser?['createdAt'] ?? DateTime.now().toIso8601String(),
    };
    _currentUser = json;
    _authStreamController.add(json);
    return json;
  }

  @override
  Future<void> signOut() async {
    _checkError();
    _currentUser = null;
    _authStreamController.add(null);
  }

  @override
  Map<String, dynamic>? get currentUserData => _currentUser;

  @override
  Stream<Map<String, dynamic>?> get authStateChanges =>
      _authStreamController.stream;

  void dispose() {
    _authStreamController.close();
  }
}

class _MockAccount {
  final String password;
  final Map<String, dynamic> json;

  _MockAccount({required this.password, required this.json});
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  late MockAuthProvider provider;
  late AuthService service;

  setUp(() {
    provider = MockAuthProvider();
    service = AuthService(provider: provider);
  });

  tearDown(() {
    provider.dispose();
  });

  // ---------------------------------------------------------------------------
  // signInAnonymously
  // ---------------------------------------------------------------------------

  group('signInAnonymously', () {
    test('returns UserModel with isAnonymous=true', () async {
      final user = await service.signInAnonymously();
      expect(user, isA<UserModel>());
      expect(user.isAnonymous, true);
      expect(user.uid, 'anon-uid-123');
    });

    test('sets current user after sign in', () async {
      await service.signInAnonymously();
      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.isAnonymous, true);
    });

    test('throws AuthException on provider failure', () async {
      provider.nextError = 'network-request-failed';
      expect(
        () => service.signInAnonymously(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // signInWithEmail
  // ---------------------------------------------------------------------------

  group('signInWithEmail', () {
    setUp(() {
      provider.addAccount('test@example.com', 'password123', {
        'uid': 'email-uid-001',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'isAnonymous': false,
        'referralCode': 'EMAIL001',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      });
    });

    test('returns UserModel with email on success', () async {
      final user =
          await service.signInWithEmail('test@example.com', 'password123');
      expect(user.email, 'test@example.com');
      expect(user.isAnonymous, false);
      expect(user.uid, 'email-uid-001');
    });

    test('throws AuthException on wrong password', () async {
      expect(
        () => service.signInWithEmail('test@example.com', 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on empty email', () {
      expect(
        () => service.signInWithEmail('', 'password123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on invalid email format', () {
      expect(
        () => service.signInWithEmail('not-an-email', 'password123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on short password', () {
      expect(
        () => service.signInWithEmail('test@example.com', '12345'),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on non-existent email', () async {
      expect(
        () => service.signInWithEmail('nobody@example.com', 'password123'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // signUpWithEmail
  // ---------------------------------------------------------------------------

  group('signUpWithEmail', () {
    test('creates new user on success', () async {
      final user = await service.signUpWithEmail(
        'new@example.com',
        'secure123',
        'New User',
      );
      expect(user.email, 'new@example.com');
      expect(user.displayName, 'New User');
      expect(user.isAnonymous, false);
    });

    test('throws AuthException when email already exists', () async {
      provider.addAccount('existing@example.com', 'pass', {
        'uid': 'x',
        'email': 'existing@example.com',
        'isAnonymous': false,
        'referralCode': 'X',
        'createdAt': DateTime.now().toIso8601String(),
      });

      expect(
        () => service.signUpWithEmail(
            'existing@example.com', 'pass123', 'User'),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on empty email', () {
      expect(
        () => service.signUpWithEmail('', 'password123', 'User'),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on short password', () {
      expect(
        () => service.signUpWithEmail('a@b.com', '12345', 'User'),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on empty display name', () {
      expect(
        () => service.signUpWithEmail('a@b.com', 'password123', ''),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on whitespace-only display name', () {
      expect(
        () => service.signUpWithEmail('a@b.com', 'password123', '   '),
        throwsA(isA<AuthException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // linkAnonymousToEmail
  // ---------------------------------------------------------------------------

  group('linkAnonymousToEmail', () {
    test('preserves uid from anonymous session', () async {
      await service.signInAnonymously();
      final linked = await service.linkAnonymousToEmail(
          'upgrade@example.com', 'secure123');

      expect(linked.uid, 'anon-uid-123'); // same uid
      expect(linked.email, 'upgrade@example.com');
      expect(linked.isAnonymous, false);
    });

    test('throws AuthException on invalid email', () async {
      await service.signInAnonymously();
      expect(
        () => service.linkAnonymousToEmail('bad-email', 'secure123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on short password', () async {
      await service.signInAnonymously();
      expect(
        () => service.linkAnonymousToEmail('a@b.com', '123'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // signOut
  // ---------------------------------------------------------------------------

  group('signOut', () {
    test('clears current user', () async {
      await service.signInAnonymously();
      expect(service.currentUser, isNotNull);

      await service.signOut();
      expect(service.currentUser, isNull);
    });

    test('throws AppException on provider failure', () async {
      provider.nextError = 'some-error';
      expect(
        () => service.signOut(),
        throwsA(isA<AppException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // authStateChanges
  // ---------------------------------------------------------------------------

  group('authStateChanges', () {
    test('emits UserModel on sign in', () async {
      final stream = service.authStateChanges;

      // Sign in after a brief delay so the listener is ready.
      Future.microtask(() => service.signInAnonymously());

      final user = await stream.first;
      expect(user, isNotNull);
      expect(user!.isAnonymous, true);
    });

    test('emits null on sign out', () async {
      await service.signInAnonymously();

      final stream = service.authStateChanges;
      Future.microtask(() => service.signOut());

      final user = await stream.first;
      expect(user, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // currentUser
  // ---------------------------------------------------------------------------

  group('currentUser', () {
    test('returns null before any sign in', () {
      expect(service.currentUser, isNull);
    });

    test('returns UserModel after sign in', () async {
      await service.signInAnonymously();
      final user = service.currentUser;
      expect(user, isNotNull);
      expect(user!.uid, 'anon-uid-123');
    });
  });

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  group('error mapping', () {
    test('maps user-not-found to AuthException', () async {
      provider.nextError = 'user-not-found';
      expect(
        () => service.signInAnonymously(),
        throwsA(isA<AuthException>()),
      );
    });

    test('maps too-many-requests to AuthException', () async {
      provider.nextError = 'too-many-requests';
      expect(
        () => service.signInAnonymously(),
        throwsA(isA<AuthException>()),
      );
    });

    test('maps network-request-failed to NetworkException', () async {
      provider.nextError = 'network-request-failed';
      expect(
        () => service.signInAnonymously(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('maps unknown error to AuthException', () async {
      provider.nextError = 'some-unknown-error';
      expect(
        () => service.signInAnonymously(),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
