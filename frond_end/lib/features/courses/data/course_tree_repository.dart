// lib/features/courses/data/course_tree_repository.dart
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../models/course_tree_models.dart';
// 이미 정의돼있으면 그걸 재사용
import 'course_repository.dart' show AuthRequiredException, ApiException;

class CourseTreeRepository {
  final Dio _dio = DioClient.instance.dio;

  /// /api/courses/{id}/tree/ ကို တန်းခေါ်ပြီး CourseTree ပြန်ပေးမယ်
  Future<CourseTree> fetchTree(int id) async {
    final res = await _dio.get('/courses/$id/tree/');
    if (res.statusCode == 200) {
      return CourseTree.fromJson(res.data as Map<String, dynamic>);
    }

    if (res.statusCode == 401 || res.statusCode == 403) {
      final detail = (res.data is Map && (res.data as Map)['detail'] != null)
          ? (res.data as Map)['detail']
          : 'Authentication required';
      throw AuthRequiredException(detail.toString());
    }

    throw ApiException('Failed to load course tree (${res.statusCode})');
  }
}

// (အကူအညီ) သင့် project မှာ မရှိသေးရင် ဒီကို ထည့်နိုင်
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
