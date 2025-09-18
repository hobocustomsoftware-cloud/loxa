// features/courses/data/course_repository.dart
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../models/course_meta_model.dart';
import '../models/course_tree_models.dart';
import '../models/course_summary_model.dart';

class AuthRequiredException implements Exception {
  final String message;
  AuthRequiredException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class CourseRepository {
  final _dio = DioClient.instance.dio;

  Future<CourseMeta> fetchMeta(int id) async {
    final r = await _dio.get('/courses/$id/');
    if (r.statusCode == 200) {
      final data = r.data as Map<String, dynamic>;
      return CourseMeta.fromJson(data);
    }
    if (r.statusCode == 401 || r.statusCode == 403) {
      final detail = (r.data is Map && r.data['detail'] != null)
          ? r.data['detail']
          : 'Authentication required';
      throw AuthRequiredException(detail.toString());
    }
    throw ApiException('Failed to load course meta (${r.statusCode})');
  }

  Future<CourseTree> fetchTree(int id) async {
    final r = await _dio.get('/courses/$id/tree/');
    if (r.statusCode == 200) {
      return CourseTree.fromJson(r.data as Map<String, dynamic>);
    }
    if (r.statusCode == 401 || r.statusCode == 403) {
      final detail = (r.data is Map && r.data['detail'] != null)
          ? r.data['detail']
          : 'Authentication required';
      throw AuthRequiredException(detail.toString());
    }
    throw ApiException('Failed to load course tree (${r.statusCode})');
  }

  // list endpoint (home)
  Future<List<CourseSummary>> fetchCourses({
    int? levelId,
    String? search,
  }) async {
    final r = await _dio.get(
      '/courses/',
      queryParameters: {
        if (levelId != null) 'level': levelId,
        if (search != null && search.trim().isNotEmpty)
          'search': search!.trim(),
      },
    );
    if (r.statusCode == 200) {
      final m = r.data as Map<String, dynamic>;
      final results = (m['results'] as List).cast<Map<String, dynamic>>();
      return results.map(CourseSummary.fromJson).toList();
    }
    throw ApiException('Failed to load courses (${r.statusCode})');
  }
}
