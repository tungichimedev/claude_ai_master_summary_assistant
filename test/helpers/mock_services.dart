/// In-memory mock implementations of all abstract service interfaces.
///
/// Each mock uses simple in-memory state (Maps, Lists) and supports:
/// - **Error injection** via [shouldThrow] / [errorToThrow] fields.
/// - **Call tracking** via [callLog] for verifying interactions.
/// - **Reset** to clear state between tests.
library;

import 'dart:async';

import 'package:ai_master/services/auth_service.dart';
import 'package:ai_master/services/clipboard_service.dart';
import 'package:ai_master/services/library_service.dart';
import 'package:ai_master/services/streak_service.dart';
import 'package:ai_master/services/subscription_service.dart';
import 'package:ai_master/services/usage_service.dart';

import 'test_factories.dart';

// =============================================================================
// MockLibraryStorage
// =============================================================================

/// In-memory implementation of [LibraryStorage] for testing.
///
/// Stores summaries in a `Map<String, Map<String, dynamic>>` keyed by `id`.
class MockLibraryStorage implements LibraryStorage {
  final Map<String, Map<String, dynamic>> _store = {};

  /// When true, all operations throw [errorToThrow].
  bool shouldThrow = false;

  /// The error to throw when [shouldThrow] is true.
  Object errorToThrow = Exception('MockLibraryStorage error');

  /// Log of method calls for verification: ['put', 'delete', 'get', ...].
  final List<String> callLog = [];

  /// Pre-populate the store with data for testing.
  void seed(List<Map<String, dynamic>> items) {
    for (final item in items) {
      final id = item['id'] as String? ?? '';
      _store[id] = Map<String, dynamic>.from(item);
    }
  }

  void reset() {
    _store.clear();
    callLog.clear();
    shouldThrow = false;
  }

  void _maybeThrow() {
    if (shouldThrow) throw errorToThrow;
  }

  @override
  Future<void> put(Map<String, dynamic> json) async {
    callLog.add('put');
    _maybeThrow();
    final id = json['id'] as String? ?? '';
    _store[id] = Map<String, dynamic>.from(json);
  }

  @override
  Future<void> delete(String id) async {
    callLog.add('delete');
    _maybeThrow();
    _store.remove(id);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> changes) async {
    callLog.add('update');
    _maybeThrow();
    final existing = _store[id];
    if (existing != null) {
      existing.addAll(changes);
    }
  }

  @override
  Future<Map<String, dynamic>?> get(String id) async {
    callLog.add('get');
    _maybeThrow();
    final item = _store[id];
    return item != null ? Map<String, dynamic>.from(item) : null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    callLog.add('getAll');
    _maybeThrow();
    return _store.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> search(String query) async {
    callLog.add('search');
    _maybeThrow();
    final lowerQuery = query.toLowerCase();
    return _store.values
        .where((item) {
          final title = (item['title'] as String? ?? '').toLowerCase();
          final paragraph =
              (item['paragraphSummary'] as String? ?? '').toLowerCase();
          return title.contains(lowerQuery) || paragraph.contains(lowerQuery);
        })
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> filterByField(
    String field,
    String value,
  ) async {
    callLog.add('filterByField');
    _maybeThrow();
    return _store.values
        .where((item) => item[field]?.toString() == value)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<int> count() async {
    callLog.add('count');
    _maybeThrow();
    return _store.length;
  }
}

// =============================================================================
// MockAuthProvider
// =============================================================================

/// In-memory implementation of [AuthProvider] for testing.
///
/// Configurable to return specific user data or throw errors.
class MockAuthProvider implements AuthProvider {
  /// The user data to return on sign-in operations.
  /// Set this before calling sign-in methods.
  Map<String, dynamic>? userDataToReturn;

  /// When true, all operations throw [errorToThrow].
  bool shouldThrow = false;

  /// The error to throw when [shouldThrow] is true.
  Object errorToThrow = Exception('MockAuthProvider error');

  /// Log of method calls for verification.
  final List<String> callLog = [];

  /// Internal current user state.
  Map<String, dynamic>? _currentUser;

  /// Controller for auth state changes stream.
  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  MockAuthProvider() {
    // Provide sensible default user data.
    userDataToReturn = TestFactories.createUserJson();
  }

  void reset() {
    callLog.clear();
    _currentUser = null;
    shouldThrow = false;
    userDataToReturn = TestFactories.createUserJson();
  }

  void dispose() {
    _authStateController.close();
  }

  void _maybeThrow() {
    if (shouldThrow) throw errorToThrow;
  }

  /// Simulate an auth state change from outside (e.g., token refresh).
  void emitAuthState(Map<String, dynamic>? userData) {
    _currentUser = userData;
    _authStateController.add(userData);
  }

  @override
  Future<Map<String, dynamic>> signInAnonymously() async {
    callLog.add('signInAnonymously');
    _maybeThrow();
    final data = userDataToReturn ??
        TestFactories.createUserJson(isAnonymous: true);
    _currentUser = data;
    _authStateController.add(data);
    return data;
  }

  @override
  Future<Map<String, dynamic>> signInWithEmail(
    String email,
    String password,
  ) async {
    callLog.add('signInWithEmail');
    _maybeThrow();
    final data = userDataToReturn ??
        TestFactories.createUserJson(email: email);
    _currentUser = data;
    _authStateController.add(data);
    return data;
  }

  @override
  Future<Map<String, dynamic>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    callLog.add('signUpWithEmail');
    _maybeThrow();
    final data = userDataToReturn ??
        TestFactories.createUserJson(email: email);
    _currentUser = data;
    _authStateController.add(data);
    return data;
  }

  @override
  Future<Map<String, dynamic>> signInWithGoogle() async {
    callLog.add('signInWithGoogle');
    _maybeThrow();
    final data = userDataToReturn ?? TestFactories.createUserJson();
    _currentUser = data;
    _authStateController.add(data);
    return data;
  }

  @override
  Future<Map<String, dynamic>> linkAnonymousToEmail(
    String email,
    String password,
  ) async {
    callLog.add('linkAnonymousToEmail');
    _maybeThrow();
    final data = userDataToReturn ??
        TestFactories.createUserJson(email: email, isAnonymous: false);
    _currentUser = data;
    _authStateController.add(data);
    return data;
  }

  @override
  Future<Map<String, dynamic>> linkAnonymousToGoogle() async {
    callLog.add('linkAnonymousToGoogle');
    _maybeThrow();
    final data = userDataToReturn ??
        TestFactories.createUserJson(isAnonymous: false);
    _currentUser = data;
    _authStateController.add(data);
    return data;
  }

  @override
  Future<void> signOut() async {
    callLog.add('signOut');
    _maybeThrow();
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Map<String, dynamic>? get currentUserData => _currentUser;

  @override
  Stream<Map<String, dynamic>?> get authStateChanges =>
      _authStateController.stream;
}

// =============================================================================
// MockPurchaseProvider
// =============================================================================

/// In-memory implementation of [PurchaseProvider] for testing.
///
/// Configurable customer info and purchase outcomes.
class MockPurchaseProvider implements PurchaseProvider {
  /// The customer info to return on queries.
  Map<String, dynamic> customerInfoToReturn =
      TestFactories.createFreeCustomerInfoJson();

  /// When true, all operations throw [errorToThrow].
  bool shouldThrow = false;

  /// The error to throw when [shouldThrow] is true.
  Object errorToThrow = Exception('MockPurchaseProvider error');

  /// When true, purchase calls throw a "cancelled" error.
  bool shouldCancelPurchase = false;

  /// When true, purchase calls throw an "already purchased" error.
  bool shouldAlreadyPurchased = false;

  /// Log of method calls for verification.
  final List<String> callLog = [];

  /// Track the last purchased package ID.
  String? lastPurchasedPackageId;

  /// Controller for customer info stream.
  final StreamController<Map<String, dynamic>> _customerInfoController =
      StreamController<Map<String, dynamic>>.broadcast();

  void reset() {
    callLog.clear();
    customerInfoToReturn = TestFactories.createFreeCustomerInfoJson();
    shouldThrow = false;
    shouldCancelPurchase = false;
    shouldAlreadyPurchased = false;
    lastPurchasedPackageId = null;
  }

  void dispose() {
    _customerInfoController.close();
  }

  void _maybeThrow() {
    if (shouldThrow) throw errorToThrow;
  }

  /// Simulate a subscription change event (e.g., renewal, expiry).
  void emitCustomerInfo(Map<String, dynamic> info) {
    customerInfoToReturn = info;
    _customerInfoController.add(info);
  }

  @override
  Future<void> initialize(String apiKey) async {
    callLog.add('initialize');
    _maybeThrow();
  }

  @override
  Future<void> identify(String userId) async {
    callLog.add('identify');
    _maybeThrow();
  }

  @override
  Future<Map<String, dynamic>> getCustomerInfo() async {
    callLog.add('getCustomerInfo');
    _maybeThrow();
    return Map<String, dynamic>.from(customerInfoToReturn);
  }

  @override
  Future<Map<String, dynamic>> purchase(String packageId) async {
    callLog.add('purchase');
    _maybeThrow();
    if (shouldCancelPurchase) {
      throw Exception('Purchase cancelled by user (userCancelled)');
    }
    if (shouldAlreadyPurchased) {
      throw Exception('ALREADY_PURCHASED');
    }
    lastPurchasedPackageId = packageId;
    // Simulate successful purchase: upgrade to pro.
    final proInfo = TestFactories.createCustomerInfoJson();
    customerInfoToReturn = proInfo;
    return proInfo;
  }

  @override
  Future<Map<String, dynamic>> restorePurchases() async {
    callLog.add('restorePurchases');
    _maybeThrow();
    return Map<String, dynamic>.from(customerInfoToReturn);
  }

  @override
  Stream<Map<String, dynamic>> get customerInfoStream =>
      _customerInfoController.stream;
}

// =============================================================================
// MockUsageCache
// =============================================================================

/// In-memory implementation of [UsageCache] for testing.
class MockUsageCache implements UsageCache {
  Map<String, dynamic>? _cachedData;

  /// When true, all operations throw [errorToThrow].
  bool shouldThrow = false;

  /// The error to throw when [shouldThrow] is true.
  Object errorToThrow = Exception('MockUsageCache error');

  /// Log of method calls for verification.
  final List<String> callLog = [];

  /// Pre-populate the cache with data.
  void seed(Map<String, dynamic> data) {
    _cachedData = Map<String, dynamic>.from(data);
  }

  void reset() {
    _cachedData = null;
    callLog.clear();
    shouldThrow = false;
  }

  void _maybeThrow() {
    if (shouldThrow) throw errorToThrow;
  }

  @override
  Future<Map<String, dynamic>?> get() async {
    callLog.add('get');
    _maybeThrow();
    return _cachedData != null
        ? Map<String, dynamic>.from(_cachedData!)
        : null;
  }

  @override
  Future<void> put(Map<String, dynamic> data) async {
    callLog.add('put');
    _maybeThrow();
    _cachedData = Map<String, dynamic>.from(data);
  }

  @override
  Future<void> clear() async {
    callLog.add('clear');
    _maybeThrow();
    _cachedData = null;
  }
}

// =============================================================================
// MockStreakStorage
// =============================================================================

/// In-memory implementation of [StreakStorage] for testing.
class MockStreakStorage implements StreakStorage {
  Map<String, dynamic>? _data;

  /// When true, all operations throw [errorToThrow].
  bool shouldThrow = false;

  /// The error to throw when [shouldThrow] is true.
  Object errorToThrow = Exception('MockStreakStorage error');

  /// Log of method calls for verification.
  final List<String> callLog = [];

  /// Pre-populate with streak data.
  void seed(Map<String, dynamic> data) {
    _data = Map<String, dynamic>.from(data);
  }

  void reset() {
    _data = null;
    callLog.clear();
    shouldThrow = false;
  }

  void _maybeThrow() {
    if (shouldThrow) throw errorToThrow;
  }

  @override
  Future<Map<String, dynamic>?> get() async {
    callLog.add('get');
    _maybeThrow();
    return _data != null ? Map<String, dynamic>.from(_data!) : null;
  }

  @override
  Future<void> put(Map<String, dynamic> data) async {
    callLog.add('put');
    _maybeThrow();
    _data = Map<String, dynamic>.from(data);
  }
}

// =============================================================================
// MockClipboardProvider
// =============================================================================

/// In-memory implementation of [ClipboardProvider] for testing.
///
/// Set [textToReturn] to control what the clipboard contains.
class MockClipboardProvider implements ClipboardProvider {
  /// The text the clipboard should return. Set to null for empty clipboard.
  String? textToReturn;

  /// When true, getText() throws [errorToThrow].
  bool shouldThrow = false;

  /// The error to throw when [shouldThrow] is true.
  Object errorToThrow = Exception('MockClipboardProvider error');

  /// Log of method calls for verification.
  final List<String> callLog = [];

  void reset() {
    textToReturn = null;
    callLog.clear();
    shouldThrow = false;
  }

  @override
  Future<String?> getText() async {
    callLog.add('getText');
    if (shouldThrow) throw errorToThrow;
    return textToReturn;
  }
}

// =============================================================================
// Helper: Configurable mock Dio responses
// =============================================================================

/// A simple holder for configuring expected HTTP responses in tests.
///
/// Usage with `http_mock_adapter`:
/// ```dart
/// final dioAdapter = DioAdapter(dio: dio);
/// final response = MockDioResponse.success(TestFactories.createSummaryJson());
/// dioAdapter.onPost('/summarize/text', (server) {
///   server.reply(response.statusCode, response.data);
/// });
/// ```
class MockDioResponse {
  final int statusCode;
  final dynamic data;
  final Map<String, dynamic>? headers;

  const MockDioResponse({
    required this.statusCode,
    this.data,
    this.headers,
  });

  /// Create a successful (200) response.
  factory MockDioResponse.success(dynamic data) {
    return MockDioResponse(statusCode: 200, data: data);
  }

  /// Create a rate-limited (429) response.
  factory MockDioResponse.rateLimited() {
    return const MockDioResponse(
      statusCode: 429,
      data: {'error': 'Rate limit exceeded'},
    );
  }

  /// Create a server error (500) response.
  factory MockDioResponse.serverError([String? message]) {
    return MockDioResponse(
      statusCode: 500,
      data: {'error': message ?? 'Internal server error'},
    );
  }

  /// Create a not found (404) response.
  factory MockDioResponse.notFound() {
    return const MockDioResponse(
      statusCode: 404,
      data: {'error': 'Not found'},
    );
  }

  /// Create a content too large (413) response.
  factory MockDioResponse.payloadTooLarge() {
    return const MockDioResponse(
      statusCode: 413,
      data: {'error': 'Content exceeds the maximum allowed size.'},
    );
  }

  /// Create a validation error (422) response.
  factory MockDioResponse.validationError(String message) {
    return MockDioResponse(
      statusCode: 422,
      data: {'error': message},
    );
  }
}
