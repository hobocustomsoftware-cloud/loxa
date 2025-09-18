// lib/features/live/models/attendance_model.dart
class AttendanceJoinResult {
  final bool joined;
  final int attendanceId;
  AttendanceJoinResult({required this.joined, required this.attendanceId});

  factory AttendanceJoinResult.fromJson(Map<String, dynamic> j) {
    return AttendanceJoinResult(
      joined: j['joined'] == true,
      attendanceId: j['attendance_id'] is int
          ? j['attendance_id']
          : int.tryParse('${j['attendance_id'] ?? 0}') ?? 0,
    );
  }
}

class LeaveResult {
  final bool left;
  final int totalSeconds;
  LeaveResult({required this.left, required this.totalSeconds});

  factory LeaveResult.fromJson(Map<String, dynamic> j) {
    return LeaveResult(
      left: j['left'] == true,
      totalSeconds: j['total_seconds'] is int
          ? j['total_seconds']
          : int.tryParse('${j['total_seconds'] ?? 0}') ?? 0,
    );
  }
}

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

  factory AgoraTokenBundle.fromJson(Map<String, dynamic> j) {
    return AgoraTokenBundle(
      channel: j['channel'],
      uid: j['uid'].toString(),
      rtcToken: j['rtc_token'],
      rtmToken: j['rtm_token'],
      expiresIn: j['expires_in'],
    );
  }
}
