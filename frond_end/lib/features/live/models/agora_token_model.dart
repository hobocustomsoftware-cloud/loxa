// lib/features/live/models/agora_token_model.dart
class AgoraTokenBundle {
  final String channel;
  final String uid;
  final String rtcToken;
  final String rtmToken;
  final int expiresIn;

  AgoraTokenBundle({
    required this.channel,
    required this.uid,
    required this.rtcToken,
    required this.rtmToken,
    required this.expiresIn,
  });

  factory AgoraTokenBundle.fromJson(Map<String, dynamic> json) {
    return AgoraTokenBundle(
      channel: json['channel'],
      uid: json['uid'],
      rtcToken: json['rtc_token'],
      rtmToken: json['rtm_token'],
      expiresIn: json['expires_in'],
    );
  }
}
