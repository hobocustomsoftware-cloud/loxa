// lib/features/admin/data/admin_courses_repository.dart
import 'package:dio/dio.dart';

import '../../../../core/api/dio_client.dart';

class Paged<T> {
  final int count;
  final List<T> results;
  Paged({required this.count, required this.results});
}

class AdminCourse {
  final int id;
  final String title;
  final String? description;
  final String? code;
  final String? paperNo;
  final int? level;
  final int? org;
  final String? levelLabel;
  final String? programLabel;

  AdminCourse({
    required this.id,
    required this.title,
    this.description,
    this.code,
    this.paperNo,
    this.level,
    this.org,
    this.levelLabel,
    this.programLabel,
  });

  factory AdminCourse.fromJson(Map<String, dynamic> j) => AdminCourse(
    id: j['id'],
    title: j['title'] ?? '',
    description: j['description'],
    code: j['code'],
    paperNo: j['paper_no'],
    level: j['level'],
    org: j['org'],
    levelLabel: j['level_label'],
    programLabel: j['program_label'],
  );

  Map<String, dynamic> toPayload() => {
    'title': title,
    'description': description ?? '',
    'code': code,
    'paper_no': paperNo,
    'level': level,
    'org': org,
  };
}

class AdminCoursesRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<Paged<AdminCourse>> list({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await _dio.get(
      '/courses/',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'page_size': pageSize,
      },
    );
    final m = r.data as Map<String, dynamic>;
    final list = (m['results'] as List).cast<Map<String, dynamic>>();
    return Paged(
      count: m['count'] ?? list.length,
      results: list.map(AdminCourse.fromJson).toList(),
    );
  }

  Future<AdminCourse> create(AdminCourse draft) async {
    final r = await _dio.post('/courses/', data: draft.toPayload());
    return AdminCourse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<AdminCourse> update(int id, AdminCourse draft) async {
    final r = await _dio.patch('/courses/$id/', data: draft.toPayload());
    return AdminCourse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> remove(int id) async {
    await _dio.delete('/courses/$id/');
  }
}
