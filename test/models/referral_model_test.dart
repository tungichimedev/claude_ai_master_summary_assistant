import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/referral_model.dart';

void main() {
  final _fixedDate = DateTime(2025, 6, 1, 12, 0, 0);

  ReferredUser _createReferredUser({
    String displayName = 'Alice',
    DateTime? joinedAt,
    ReferralStatus status = ReferralStatus.joined,
  }) {
    return ReferredUser(
      displayName: displayName,
      joinedAt: joinedAt ?? _fixedDate,
      status: status,
    );
  }

  ReferralModel _createReferral({
    String code = 'REF123',
    List<ReferredUser>? referredUsers,
    int rewardsEarned = 2,
    String link = 'https://aimaster.app/r/REF123',
  }) {
    return ReferralModel(
      code: code,
      referredUsers: referredUsers ?? [_createReferredUser()],
      rewardsEarned: rewardsEarned,
      link: link,
    );
  }

  group('ReferralStatus enum', () {
    test('fromJson returns correct values', () {
      expect(ReferralStatus.fromJson('pending'), ReferralStatus.pending);
      expect(ReferralStatus.fromJson('joined'), ReferralStatus.joined);
    });

    test('fromJson defaults to pending for unknown', () {
      expect(ReferralStatus.fromJson('unknown'), ReferralStatus.pending);
    });

    test('toJson returns name', () {
      expect(ReferralStatus.pending.toJson(), 'pending');
      expect(ReferralStatus.joined.toJson(), 'joined');
    });
  });

  group('ReferredUser.fromJson', () {
    test('creates model with all fields present', () {
      final json = {
        'displayName': 'Alice',
        'joinedAt': _fixedDate.toIso8601String(),
        'status': 'joined',
      };

      final user = ReferredUser.fromJson(json);

      expect(user.displayName, 'Alice');
      expect(user.joinedAt, _fixedDate);
      expect(user.status, ReferralStatus.joined);
    });

    test('applies defaults for missing fields', () {
      final user = ReferredUser.fromJson(<String, dynamic>{});

      expect(user.displayName, '');
      expect(user.joinedAt, isNull);
      expect(user.status, ReferralStatus.pending);
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final original = _createReferredUser();
      final restored = ReferredUser.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('ReferredUser.copyWith', () {
    test('copies with changed status', () {
      final user = _createReferredUser(status: ReferralStatus.pending);
      final copy = user.copyWith(status: ReferralStatus.joined);

      expect(copy.status, ReferralStatus.joined);
      expect(copy.displayName, user.displayName);
    });

    test('copies with changed displayName', () {
      final user = _createReferredUser(displayName: 'Alice');
      final copy = user.copyWith(displayName: 'Bob');

      expect(copy.displayName, 'Bob');
    });
  });

  group('ReferredUser Equatable', () {
    test('two users with same values are equal', () {
      final a = _createReferredUser();
      final b = _createReferredUser();

      expect(a, equals(b));
    });

    test('two users with different name are not equal', () {
      final a = _createReferredUser(displayName: 'Alice');
      final b = _createReferredUser(displayName: 'Bob');

      expect(a, isNot(equals(b)));
    });
  });

  group('ReferralModel.fromJson', () {
    test('creates model with all fields and nested referredUsers', () {
      final json = {
        'code': 'REF123',
        'referredUsers': [
          {
            'displayName': 'Alice',
            'joinedAt': _fixedDate.toIso8601String(),
            'status': 'joined',
          },
          {
            'displayName': 'Bob',
            'status': 'pending',
          },
        ],
        'rewardsEarned': 1,
        'link': 'https://aimaster.app/r/REF123',
      };

      final model = ReferralModel.fromJson(json);

      expect(model.code, 'REF123');
      expect(model.referredUsers, hasLength(2));
      expect(model.referredUsers[0].displayName, 'Alice');
      expect(model.referredUsers[0].status, ReferralStatus.joined);
      expect(model.referredUsers[1].displayName, 'Bob');
      expect(model.referredUsers[1].status, ReferralStatus.pending);
      expect(model.rewardsEarned, 1);
      expect(model.link, 'https://aimaster.app/r/REF123');
    });

    test('applies defaults for missing fields', () {
      final model = ReferralModel.fromJson(<String, dynamic>{});

      expect(model.code, '');
      expect(model.referredUsers, isEmpty);
      expect(model.rewardsEarned, 0);
      expect(model.link, '');
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final original = _createReferral(
        referredUsers: [
          _createReferredUser(displayName: 'Alice'),
          _createReferredUser(
            displayName: 'Bob',
            status: ReferralStatus.pending,
            joinedAt: null,
          ),
        ],
      );
      // Note: ReferredUser with joinedAt: null will have null through roundtrip
      final restored = ReferralModel.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('ReferralModel.toJson', () {
    test('serializes nested referredUsers correctly', () {
      final model = _createReferral();
      final json = model.toJson();

      expect(json['code'], 'REF123');
      expect(json['referredUsers'], isA<List>());
      expect((json['referredUsers'] as List).first['displayName'], 'Alice');
      expect(json['rewardsEarned'], 2);
      expect(json['link'], 'https://aimaster.app/r/REF123');
    });
  });

  group('ReferralModel.copyWith', () {
    test('copies with no changes returns equal model', () {
      final model = _createReferral();
      expect(model.copyWith(), equals(model));
    });

    test('copies with changed code', () {
      final model = _createReferral(code: 'REF123');
      final copy = model.copyWith(code: 'REF456');

      expect(copy.code, 'REF456');
      expect(copy.link, model.link);
    });

    test('copies with changed rewardsEarned', () {
      final model = _createReferral(rewardsEarned: 2);
      final copy = model.copyWith(rewardsEarned: 5);

      expect(copy.rewardsEarned, 5);
    });
  });

  group('ReferralModel Equatable', () {
    test('two models with same values are equal', () {
      final a = _createReferral();
      final b = _createReferral();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two models with different code are not equal', () {
      final a = _createReferral(code: 'REF123');
      final b = _createReferral(code: 'REF456');

      expect(a, isNot(equals(b)));
    });
  });

  group('ReferralModel.successfulReferrals', () {
    test('counts only joined users', () {
      final model = _createReferral(
        referredUsers: [
          _createReferredUser(
              displayName: 'Alice', status: ReferralStatus.joined),
          _createReferredUser(
              displayName: 'Bob', status: ReferralStatus.pending),
          _createReferredUser(
              displayName: 'Charlie', status: ReferralStatus.joined),
        ],
      );

      expect(model.successfulReferrals, 2);
    });

    test('returns 0 when no users have joined', () {
      final model = _createReferral(
        referredUsers: [
          _createReferredUser(
              displayName: 'Alice', status: ReferralStatus.pending),
          _createReferredUser(
              displayName: 'Bob', status: ReferralStatus.pending),
        ],
      );

      expect(model.successfulReferrals, 0);
    });

    test('returns 0 when referredUsers is empty', () {
      final model = _createReferral(referredUsers: []);

      expect(model.successfulReferrals, 0);
    });

    test('returns count equal to list length when all have joined', () {
      final model = _createReferral(
        referredUsers: [
          _createReferredUser(
              displayName: 'Alice', status: ReferralStatus.joined),
          _createReferredUser(
              displayName: 'Bob', status: ReferralStatus.joined),
        ],
      );

      expect(model.successfulReferrals, 2);
    });
  });
}
