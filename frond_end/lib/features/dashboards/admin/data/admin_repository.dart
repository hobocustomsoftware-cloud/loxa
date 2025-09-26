// lib/features/admin/data/admin_repository.dart
import '../../../../core/api/dio_client.dart';

class AdminStats {
  final int courses, modules, lessons, sessions, attendance;
  AdminStats({
    required this.courses,
    required this.modules,
    required this.lessons,
    required this.sessions,
    required this.attendance,
  });
  factory AdminStats.fromJson(Map<String, dynamic> j) => AdminStats(
    courses: j['courses'] ?? 0,
    modules: j['modules'] ?? 0,
    lessons: j['lessons'] ?? 0,
    sessions: j['sessions'] ?? 0,
    attendance: j['attendance'] ?? 0,
  );
}

class AdminRepository {
  final _dio = DioClient.instance.dio;
  Future<AdminStats> stats() async {
    final r = await _dio.get('/admin/stats/');
    return AdminStats.fromJson(r.data as Map<String, dynamic>);
  }
}
