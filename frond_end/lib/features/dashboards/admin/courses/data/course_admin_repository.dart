import 'package:dio/dio.dart';

import '../../../../../core/api/dio_client.dart';
import 'course_admin_models.dart';

class CourseAdminRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<AdminCourse>> list({String? search}) async {
    final r = await _dio.get(
      '/courses/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    // DRF paginated → {count, results: [...]}
    final data = r.data;
    final List results = (data is Map && data['results'] is List)
        ? data['results']
        : (data as List);
    return results.map((e) => AdminCourse.fromJson(e)).toList();
  }

  Future<AdminCourse> retrieve(int id) async {
    final r = await _dio.get('/courses/$id/');
    return AdminCourse.fromJson(r.data);
  }

  Future<AdminCourse> create(AdminCourse payload) async {
    final r = await _dio.post('/courses/', data: payload.toJson());
    return AdminCourse.fromJson(r.data);
  }

  Future<AdminCourse> update(int id, AdminCourse payload) async {
    final r = await _dio.put('/courses/$id/', data: payload.toJson());
    return AdminCourse.fromJson(r.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/courses/$id/');
  }
}
