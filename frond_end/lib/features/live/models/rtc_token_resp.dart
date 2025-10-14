// lib/features/live/data/models/rtc_token_resp.dart
class RtcTokenResp {
  final String token;
  final String channel;
  final int uid;
  final String appId;
  final String role; // 'host' | 'audience'

  const RtcTokenResp({
    required this.token,
    required this.channel,
    required this.uid,
    required this.appId,
    required this.role,
  });

  factory RtcTokenResp.fromJson(Map<String, dynamic> d) {
    return RtcTokenResp(
      token: (d['token'] as String?) ?? '',
      channel: (d['channel'] as String?) ?? '',
      uid: (d['uid'] as num?)?.toInt() ?? 0,
      appId: (d['app_id'] as String?) ?? '',
      role: (d['role'] as String?) ?? 'audience',
    );
  }
}
