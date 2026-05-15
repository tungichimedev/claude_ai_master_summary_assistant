// Fix for Issue #56 - Referral Service Implementation
import 'dart:math';

class ReferralService {
  final Map<String, String> _referralLinks = {};
  final Map<String, List<String>> _referrals = {};

  String generateReferralLink(String uid) {
    final code = _generateCode();
    _referralLinks[uid] = code;
    return 'aimaster.app/r/\$code';
  }

  String _generateCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Map<String, dynamic> getReferralStats(String uid) {
    return {
      'friends_joined': (_referrals[uid] ?? []).length,
      'pending': 0,
      'rewards_earned': (_referrals[uid] ?? []).length,
    };
  }

  bool claimReferral(String referralCode, String newUserId, String deviceFingerprint) {
    final referrer = _referralLinks.entries
        .where((e) => e.value == referralCode)
        .map((e) => e.key)
        .firstOrNull;
    if (referrer == null) return false;
    _referrals.putIfAbsent(referrer, () => []).add(newUserId);
    return true;
  }
}
