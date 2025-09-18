class Seat {
  final String id;
  final String session;
  final String? user;
  final String status;
  Seat({
    required this.id,
    required this.session,
    this.user,
    required this.status,
  });
  factory Seat.fromJson(Map<String, dynamic> j) => Seat(
    id: '${j['id'] ?? j['uuid'] ?? j['pk']}',
    session: '${j['session']}',
    user: j['user']?.toString(),
    status: j['status'] ?? 'free',
  );
}
