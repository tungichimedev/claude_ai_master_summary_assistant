// Fix #56
class ReferralService {
  String gen(String uid) => 'aimaster.app/r/' + uid.substring(0,8);
}
