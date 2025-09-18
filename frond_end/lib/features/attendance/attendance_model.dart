class Attendance {
  final String id;
  final String user;
  final String status;
  Attendance({required this.id, required this.user, required this.status});
  factory Attendance.fromJson(Map<String, dynamic> j) => Attendance(
    id: '${j['id'] ?? j['uuid'] ?? j['pk']}',
    user: j['user']?.toString() ?? j['student_name'] ?? 'User',
    status: j['status'] ?? 'unknown',
  );
}
