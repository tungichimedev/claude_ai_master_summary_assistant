import 'package:equatable/equatable.dart';

/// Status of a referral invitation.
enum ReferralStatus {
  pending,
  joined;

  factory ReferralStatus.fromJson(String value) {
    return ReferralStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReferralStatus.pending,
    );
  }

  String toJson() => name;
}

/// A user who was referred by the current user.
class ReferredUser extends Equatable {
  final String displayName;
  final DateTime? joinedAt;
  final ReferralStatus status;

  const ReferredUser({
    required this.displayName,
    this.joinedAt,
    this.status = ReferralStatus.pending,
  });

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      displayName: json['displayName'] as String? ?? '',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : null,
      status: ReferralStatus.fromJson(json['status'] as String? ?? 'pending'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'joinedAt': joinedAt?.toIso8601String(),
      'status': status.toJson(),
    };
  }

  ReferredUser copyWith({
    String? displayName,
    DateTime? joinedAt,
    ReferralStatus? status,
  }) {
    return ReferredUser(
      displayName: displayName ?? this.displayName,
      joinedAt: joinedAt ?? this.joinedAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [displayName, joinedAt, status];
}

/// The user's referral program data.
///
/// [rewardsEarned] counts weeks of Pro access granted through referrals.
/// [link] is the full deep link URL that can be shared.
class ReferralModel extends Equatable {
  final String code;
  final List<ReferredUser> referredUsers;
  final int rewardsEarned;
  final String link;

  const ReferralModel({
    required this.code,
    this.referredUsers = const [],
    this.rewardsEarned = 0,
    required this.link,
  });

  /// Number of referrals that have successfully joined.
  int get successfulReferrals =>
      referredUsers.where((u) => u.status == ReferralStatus.joined).length;

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      code: json['code'] as String? ?? '',
      referredUsers: (json['referredUsers'] as List<dynamic>?)
              ?.map((e) => ReferredUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rewardsEarned: json['rewardsEarned'] as int? ?? 0,
      link: json['link'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'referredUsers': referredUsers.map((u) => u.toJson()).toList(),
      'rewardsEarned': rewardsEarned,
      'link': link,
    };
  }

  ReferralModel copyWith({
    String? code,
    List<ReferredUser>? referredUsers,
    int? rewardsEarned,
    String? link,
  }) {
    return ReferralModel(
      code: code ?? this.code,
      referredUsers: referredUsers ?? this.referredUsers,
      rewardsEarned: rewardsEarned ?? this.rewardsEarned,
      link: link ?? this.link,
    );
  }

  @override
  List<Object?> get props => [code, referredUsers, rewardsEarned, link];
}
