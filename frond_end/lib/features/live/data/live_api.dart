// lib/features/live/data/live_api.dart
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';

class LiveApi {
  LiveApi._();
  static final LiveApi instance = LiveApi._();
  final Dio _dio = DioClient.instance.client;

  Future<List<Map<String, dynamic>>> listSessions({
    int? org,
    bool mine = false,
  }) async {
    final r = await _dio.get(
      'live-sessions/', // NO leading slash
      queryParameters: {
        if (org != null) 'org': org,
        if (mine) 'owner': 'me',
        'ordering': '-created_at',
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
    final r = await _dio.post('live-sessions/', data: {'title': title});
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<int> join(int sessionId) async {
    final r = await _dio.post('live-sessions/$sessionId/join/');
    return (r.data['attendance_id'] as num?)?.toInt() ?? 0;
  }

  // ✅ appId (server ရဲ့ app_id) ကိုပါ ယူမယ်
  Future<({String channel, String token, int uid, String appId})> token(
    int sessionId, {
    required bool asHost,
  }) async {
    final r = await _dio.get(
      'live-sessions/$sessionId/rtc-token',
      queryParameters: {'role': asHost ? 'host' : 'audience'},
    );
    final d = r.data as Map;
    return (
      channel: (d['channel'] as String?) ?? '',
      token: (d['token'] as String?) ?? '',
      uid: (d['uid'] as num).toInt(),
      appId: (d['app_id'] as String?) ?? '', // 👈 add this line
    );
  }

  Future<void> leave(int sessionId) async {
    await _dio.post('live-sessions/$sessionId/leave/');
  }
}
