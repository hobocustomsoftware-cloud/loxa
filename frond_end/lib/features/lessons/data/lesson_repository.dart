import '../../../core/api/dio_client.dart';

class LessonRepository {
  final _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> list(int moduleId) async {
    final r = await _dio.get(
      '/lessons/',
      queryParameters: {'module': moduleId},
    );
    return (r.data['results'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create({
    required int moduleId,
    required String title,
    int? order,
    bool? isPreview, // backend field ရှိ/မရှိ ပေါင်းစပ်
    bool? published,
  }) async {
    final r = await _dio.post(
      '/lessons/',
      data: {
        'module': moduleId,
        'title': title,
        if (order != null) 'order': order,
        if (isPreview != null) 'is_preview': isPreview,
        if (published != null) 'published': published,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(
    int id, {
    String? title,
    int? order,
    bool? isPreview,
    bool? published,
  }) async {
    final r = await _dio.patch(
      '/lessons/$id/',
      data: {
        if (title != null) 'title': title,
        if (order != null) 'order': order,
        if (isPreview != null) 'is_preview': isPreview,
        if (published != null) 'published': published,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  Future<void> delete(int id) async => _dio.delete('/lessons/$id/');
}
