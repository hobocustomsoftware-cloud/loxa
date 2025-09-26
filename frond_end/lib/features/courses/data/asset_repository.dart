import '../../../core/api/dio_client.dart';
import '../models/course_summary_model.dart';
import '../models/course_meta_model.dart';

class CourseRepository {
  final _dio = DioClient.instance.dio;

  Future<List<CourseSummary>> fetchCourses() async {
    final r = await _dio.get('/courses/');
    final results = (r.data['results'] as List).cast<Map<String, dynamic>>();
    return results.map(CourseSummary.fromJson).toList();
  }

  Future<CourseMeta> createCourse(
    String title, {
    String? code,
    String? description,
  }) async {
    final r = await _dio.post(
      '/courses/',
      data: {
        'title': title,
        if (code != null) 'code': code,
        if (description != null) 'description': description,
      },
    );
    return CourseMeta.fromJson(r.data);
  }

  Future<CourseMeta> updateCourse(
    int id, {
    String? title,
    String? code,
    String? description,
  }) async {
    final r = await _dio.patch(
      '/courses/$id/',
      data: {
        if (title != null) 'title': title,
        if (code != null) 'code': code,
        if (description != null) 'description': description,
      },
    );
    return CourseMeta.fromJson(r.data);
  }

  Future<void> deleteCourse(int id) async {
    await _dio.delete('/courses/$id/');
  }
}
