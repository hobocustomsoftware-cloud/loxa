// lib/features/live/data/live_repository.dart
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../models/live_session_model.dart';
import '../models/agora_token_model.dart';

class LiveRepository {
  final _dio = DioClient.instance.dio;

  Future<LiveSession> getSession(int id) async {
    final r = await _dio.get('/sessions/$id/');
    if (r.statusCode == 200) {
      return LiveSession.fromJson(r.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load session');
  }

  Future<void> join(int sessionId) async {
    final r = await _dio.post('/sessions/$sessionId/join/');
    if (r.statusCode != 200) {
      throw Exception('Join failed: ${r.statusCode}');
    }
  }

  Future<void> leave(int sessionId) async {
    final r = await _dio.post('/sessions/$sessionId/leave/');
    if (r.statusCode != 200) {
      throw Exception('Leave failed: ${r.statusCode}');
    }
  }

  Future<AgoraTokenBundle> getAgoraToken({
    required String channel,
    String role = 'subscriber',
  }) async {
    final r = await _dio.post(
      '/agora/token/',
      data: {"channel": channel, "role": role},
    );
    if (r.statusCode == 200) {
      return AgoraTokenBundle.fromJson(r.data as Map<String, dynamic>);
    }
    throw Exception('Failed to get Agora token');
  }
}
