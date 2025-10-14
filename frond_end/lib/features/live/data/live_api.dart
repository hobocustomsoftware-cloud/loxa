import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';

class LiveApi {
  LiveApi._();
  static final LiveApi instance = LiveApi._();
  final Dio _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> listSessions({
    int? org,
    bool mine = false,
  }) async {
    final r = await _dio.get(
      '/live-sessions/',
      queryParameters: {
        if (org != null) 'org': org,
        if (mine) 'owner': 'me',
        'ordering': '-start_time',
      },
    );
    final data = r.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['results'] is List) {
      return (data['results'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createSession({required String title}) async {
    final r = await _dio.post('/live-sessions/', data: {'title': title});
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<int> join(int sessionId) async {
    final r = await _dio.post('/live-sessions/$sessionId/join/');
    return (r.data['attendance_id'] as num?)?.toInt() ?? 0;
  }

  Future<({String channel, String token, int uid, String appId, String role})>
  token(int sessionId, {required bool asHost}) async {
    final r = await _dio.get(
      '/live-sessions/$sessionId/rtc-token/',
      queryParameters: {'role': asHost ? 'host' : 'audience'},
    );
    if (r.statusCode != 200) {
      throw Exception('rtc-token ${r.statusCode}: ${r.data}');
    }
    final d = r.data as Map;
    return (
      channel: d['channel'] as String,
      token: (d['token'] as String?) ?? '',
      uid: (d['uid'] as num).toInt(),
      appId: d['app_id'] as String,
      role: (d['role'] as String?) ?? 'audience',
    );
  }

  Future<void> leave(int sessionId) async {
    await _dio.post('/live-sessions/$sessionId/leave/');
  }
}
