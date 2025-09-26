import '../../../core/api/dio_client.dart';

class ModuleRepository {
  final _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> list(int courseId) async {
    final r = await _dio.get(
      '/modules/',
      queryParameters: {'course': courseId},
    );
    return (r.data['results'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create({
    required int courseId,
    required String title,
    int? order,
  }) async {
    final r = await _dio.post(
      '/modules/',
      data: {
        'course': courseId,
        'title': title,
        if (order != null) 'order': order,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(
    int id, {
    String? title,
    int? order,
  }) async {
    final r = await _dio.patch(
      '/modules/$id/',
      data: {
        if (title != null) 'title': title,
        if (order != null) 'order': order,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  Future<void> delete(int id) async => _dio.delete('/modules/$id/');
}
