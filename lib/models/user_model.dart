import 'package:equatable/equatable.dart';

/// The user's subscription tier.
enum UserTier {
  free,
  pro;

  factory UserTier.fromJson(String value) {
    return UserTier.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserTier.free,
    );
  }

  String toJson() => name;
}

/// Represents the authenticated user's profile and account state.
class UserModel extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final UserTier tier;
  final DateTime? trialEndsAt;
  final int streakCount;
  final String referralCode;
  final DateTime createdAt;
  final bool isAnonymous;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.tier = UserTier.free,
    this.trialEndsAt,
    this.streakCount = 0,
    required this.referralCode,
    required this.createdAt,
    this.isAnonymous = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      tier: UserTier.fromJson(json['tier'] as String? ?? 'free'),
      trialEndsAt: json['trialEndsAt'] != null
          ? DateTime.parse(json['trialEndsAt'] as String)
          : null,
      streakCount: json['streakCount'] as int? ?? 0,
      referralCode: json['referralCode'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'tier': tier.toJson(),
      'trialEndsAt': trialEndsAt?.toIso8601String(),
      'streakCount': streakCount,
      'referralCode': referralCode,
      'createdAt': createdAt.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserTier? tier,
    DateTime? trialEndsAt,
    int? streakCount,
    String? referralCode,
    DateTime? createdAt,
    bool? isAnonymous,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      tier: tier ?? this.tier,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      streakCount: streakCount ?? this.streakCount,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        tier,
        trialEndsAt,
        streakCount,
        referralCode,
        createdAt,
        isAnonymous,
      ];
}
