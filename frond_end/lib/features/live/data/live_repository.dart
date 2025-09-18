// lib/features/live/data/live_repository.dart
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../models/live_session_model.dart';
import '../models/attendance_model.dart';

class LiveApiException implements Exception {
  final String message;
  LiveApiException(this.message);
  @override
  String toString() => message;
}

class AuthRequiredException implements Exception {
  final String message;
  AuthRequiredException(this.message);
  @override
  String toString() => message;
}

class LiveRepository {
  final _dio = DioClient.instance.dio;

  Future<LiveSession> getSession(int id) async {
    final r = await _dio.get('/sessions/$id/');
    if (r.statusCode == 200) {
      return LiveSession.fromJson(r.data as Map<String, dynamic>);
    }
    if (r.statusCode == 401 || r.statusCode == 403) {
      throw AuthRequiredException(r.data?['detail'] ?? 'Auth required');
    }
    throw LiveApiException('Failed to load session (${r.statusCode})');
  }

  Future<AttendanceJoinResult> join(int id) async {
    final r = await _dio.post('/sessions/$id/join/');
    if (r.statusCode == 200) {
      return AttendanceJoinResult.fromJson(r.data as Map<String, dynamic>);
    }
    if (r.statusCode == 401 || r.statusCode == 403) {
      throw AuthRequiredException(r.data?['detail'] ?? 'Auth required');
    }
    throw LiveApiException('Join failed (${r.statusCode})');
  }

  Future<LeaveResult> leave(int id) async {
    final r = await _dio.post('/sessions/$id/leave/');
    if (r.statusCode == 200) {
      return LeaveResult.fromJson(r.data as Map<String, dynamic>);
    }
    if (r.statusCode == 401 || r.statusCode == 403) {
      throw AuthRequiredException(r.data?['detail'] ?? 'Auth required');
    }
    throw LiveApiException('Leave failed (${r.statusCode})');
  }

  Future<AgoraTokenBundle> getAgoraToken({
    required String channel,
    String role = 'publisher', // or 'subscriber'
    int? ttlSeconds,
  }) async {
    final r = await _dio.get(
      '/agora/token/',
      queryParameters: {
        'channel': channel,
        'role': role,
        if (ttlSeconds != null) 'ttl': ttlSeconds,
      },
    );
    if (r.statusCode == 200) {
      return AgoraTokenBundle.fromJson(r.data as Map<String, dynamic>);
    }
    if (r.statusCode == 401 || r.statusCode == 403) {
      throw AuthRequiredException(r.data?['detail'] ?? 'Auth required');
    }
    throw LiveApiException('Token failed (${r.statusCode})');
  }
}
