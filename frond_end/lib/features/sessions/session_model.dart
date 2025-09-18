class SessionModel {
  final String id, title, status;
  final String? start, end;
  SessionModel({
    required this.id,
    required this.title,
    required this.status,
    this.start,
    this.end,
  });
  factory SessionModel.fromJson(Map<String, dynamic> j) => SessionModel(
    id: '${j['id'] ?? j['uuid'] ?? j['pk']}',
    title: j['title'] ?? 'Session',
    status: j['status'] ?? (j['is_live'] == true ? 'live' : 'upcoming'),
    start: j['start_time']?.toString(),
    end: j['end_time']?.toString(),
  );
}
