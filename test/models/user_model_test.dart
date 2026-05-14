import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/user_model.dart';

void main() {
  final _fixedDate = DateTime(2025, 6, 1, 12, 0, 0);
  final _trialDate = DateTime(2025, 6, 15, 12, 0, 0);

  UserModel _createUser({
    String uid = 'user-123',
    String? email = 'test@example.com',
    String? displayName = 'Test User',
    String? photoUrl = 'https://example.com/photo.jpg',
    UserTier tier = UserTier.free,
    DateTime? trialEndsAt,
    int streakCount = 5,
    String referralCode = 'ABC123',
    DateTime? createdAt,
    bool isAnonymous = false,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      tier: tier,
      trialEndsAt: trialEndsAt,
      streakCount: streakCount,
      referralCode: referralCode,
      createdAt: createdAt ?? _fixedDate,
      isAnonymous: isAnonymous,
    );
  }

  group('UserTier', () {
    test('fromJson returns correct enum for valid values', () {
      expect(UserTier.fromJson('free'), UserTier.free);
      expect(UserTier.fromJson('pro'), UserTier.pro);
    });

    test('fromJson defaults to free for unknown value', () {
      expect(UserTier.fromJson('premium'), UserTier.free);
      expect(UserTier.fromJson(''), UserTier.free);
    });

    test('toJson returns name string', () {
      expect(UserTier.free.toJson(), 'free');
      expect(UserTier.pro.toJson(), 'pro');
    });
  });

  group('UserModel.fromJson', () {
    test('creates model with all fields present', () {
      final json = {
        'uid': 'user-123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoUrl': 'https://example.com/photo.jpg',
        'tier': 'pro',
        'trialEndsAt': _trialDate.toIso8601String(),
        'streakCount': 10,
        'referralCode': 'ABC123',
        'createdAt': _fixedDate.toIso8601String(),
        'isAnonymous': false,
      };

      final model = UserModel.fromJson(json);

      expect(model.uid, 'user-123');
      expect(model.email, 'test@example.com');
      expect(model.displayName, 'Test User');
      expect(model.photoUrl, 'https://example.com/photo.jpg');
      expect(model.tier, UserTier.pro);
      expect(model.trialEndsAt, _trialDate);
      expect(model.streakCount, 10);
      expect(model.referralCode, 'ABC123');
      expect(model.createdAt, _fixedDate);
      expect(model.isAnonymous, isFalse);
    });

    test('applies defaults for missing/null fields', () {
      final model = UserModel.fromJson(<String, dynamic>{});

      expect(model.uid, '');
      expect(model.email, isNull);
      expect(model.displayName, isNull);
      expect(model.photoUrl, isNull);
      expect(model.tier, UserTier.free);
      expect(model.trialEndsAt, isNull);
      expect(model.streakCount, 0);
      expect(model.referralCode, '');
      expect(model.isAnonymous, isFalse);
    });

    test('handles anonymous user', () {
      final json = {
        'uid': 'anon-456',
        'isAnonymous': true,
        'createdAt': _fixedDate.toIso8601String(),
        'referralCode': '',
      };

      final model = UserModel.fromJson(json);
      expect(model.isAnonymous, isTrue);
      expect(model.email, isNull);
      expect(model.displayName, isNull);
    });
  });

  group('UserModel.toJson', () {
    test('serializes all fields correctly', () {
      final model = _createUser(trialEndsAt: _trialDate);
      final json = model.toJson();

      expect(json['uid'], 'user-123');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
      expect(json['photoUrl'], 'https://example.com/photo.jpg');
      expect(json['tier'], 'free');
      expect(json['trialEndsAt'], _trialDate.toIso8601String());
      expect(json['streakCount'], 5);
      expect(json['referralCode'], 'ABC123');
      expect(json['createdAt'], _fixedDate.toIso8601String());
      expect(json['isAnonymous'], isFalse);
    });

    test('serializes null optional fields as null', () {
      final model = _createUser(
        email: null,
        displayName: null,
        photoUrl: null,
        trialEndsAt: null,
      );
      final json = model.toJson();

      expect(json['email'], isNull);
      expect(json['displayName'], isNull);
      expect(json['photoUrl'], isNull);
      expect(json['trialEndsAt'], isNull);
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final original = _createUser(trialEndsAt: _trialDate, tier: UserTier.pro);
      final restored = UserModel.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('UserModel.copyWith', () {
    test('copies with no changes returns equal model', () {
      final model = _createUser();
      expect(model.copyWith(), equals(model));
    });

    test('copies with changed tier', () {
      final model = _createUser(tier: UserTier.free);
      final copy = model.copyWith(tier: UserTier.pro);

      expect(copy.tier, UserTier.pro);
      expect(copy.uid, model.uid);
    });

    test('copies with changed isAnonymous', () {
      final model = _createUser(isAnonymous: false);
      final copy = model.copyWith(isAnonymous: true);

      expect(copy.isAnonymous, isTrue);
    });

    test('copies with changed streakCount', () {
      final model = _createUser(streakCount: 5);
      final copy = model.copyWith(streakCount: 10);

      expect(copy.streakCount, 10);
    });
  });

  group('UserModel Equatable', () {
    test('two models with same values are equal', () {
      final a = _createUser();
      final b = _createUser();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two models with different uid are not equal', () {
      final a = _createUser(uid: 'user-1');
      final b = _createUser(uid: 'user-2');

      expect(a, isNot(equals(b)));
    });

    test('two models with different tier are not equal', () {
      final a = _createUser(tier: UserTier.free);
      final b = _createUser(tier: UserTier.pro);

      expect(a, isNot(equals(b)));
    });
  });

  group('UserModel isAnonymous', () {
    test('isAnonymous defaults to false', () {
      final model = _createUser();
      expect(model.isAnonymous, isFalse);
    });

    test('isAnonymous can be set to true', () {
      final model = _createUser(isAnonymous: true);
      expect(model.isAnonymous, isTrue);
    });
  });
}
