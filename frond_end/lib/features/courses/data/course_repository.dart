import '../../../core/api/dio_client.dart';
import '../models/course_summary_model.dart';
import '../models/course_meta_model.dart';

class CourseRepository {
  final _dio = DioClient.instance.dio;

  // LIST (paginated)
  Future<List<CourseSummary>> fetchCourses({
    String? search,
    int? levelId,
  }) async {
    final r = await _dio.get(
      '/courses/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (levelId != null) 'level': levelId,
      },
    );
    final results = (r.data['results'] as List).cast<Map<String, dynamic>>();
    return results.map(CourseSummary.fromJson).toList();
  }

  // RETRIEVE (detail/meta)
  Future<CourseMeta> fetchMeta(int id) async {
    final r = await _dio.get('/courses/$id/');
    return CourseMeta.fromJson(r.data as Map<String, dynamic>);
  }

  // CREATE
  Future<CourseMeta> createCourse(
    String text, {
    required String title,
    String? code,
    String? paperNo,
    int? level, // backend expects level id
    String? description,
  }) async {
    final r = await _dio.post(
      '/courses/',
      data: {
        'title': title,
        if (code != null) 'code': code,
        if (paperNo != null) 'paper_no': paperNo,
        if (level != null) 'level': level,
        if (description != null) 'description': description,
      },
    );
    return CourseMeta.fromJson(r.data as Map<String, dynamic>);
  }

  // UPDATE (PUT/PATCH)
  Future<CourseMeta> updateCourse(
    int id, {
    String? title,
    String? code,
    String? paperNo,
    int? level,
    String? description,
  }) async {
    final r = await _dio.patch(
      '/courses/$id/',
      data: {
        if (title != null) 'title': title,
        if (code != null) 'code': code,
        if (paperNo != null) 'paper_no': paperNo,
        if (level != null) 'level': level,
        if (description != null) 'description': description,
      },
    );
    return CourseMeta.fromJson(r.data as Map<String, dynamic>);
  }

  // DELETE
  Future<void> deleteCourse(int id) async {
    await _dio.delete('/courses/$id/');
  }
}

class AuthRequiredException implements Exception {
  final String message;
  AuthRequiredException(this.message);

  @override
  String toString() => message;
}
