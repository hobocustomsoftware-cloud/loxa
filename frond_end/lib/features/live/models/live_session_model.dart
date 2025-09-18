// lib/features/live/models/live_session_model.dart
class LiveSession {
  final int id;
  final String title;
  final String channelName; // backend: channel_name
  final int? maxParticipants;

  LiveSession({
    required this.id,
    required this.title,
    required this.channelName,
    this.maxParticipants,
  });

  factory LiveSession.fromJson(Map<String, dynamic> j) {
    return LiveSession(
      id: j['id'],
      title: j['title'] ?? 'Session',
      channelName: j['channel_name'] ?? j['channelName'] ?? '',
      maxParticipants: j['max_participants'],
    );
  }
}
