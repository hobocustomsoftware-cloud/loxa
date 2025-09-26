// lib/features/auth/data/auth_repository.dart
import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';
import '../models/me.dart';

class TokenPair {
  final String access;
  final String? refresh;
  const TokenPair({required this.access, this.refresh});
}

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final Dio _dio = DioClient.instance.dio;

  String? _access;
  String? _refresh;
  Me? _me;
  bool _meLoaded = false;

  // expose to others (DioClient, controllers…)
  String? get accessToken => _access;
  String? get refreshToken => _refresh;
  Me? get me => _me;
  bool get meLoaded => _meLoaded;

  void clearCache() {
    _me = null;
    _meLoaded = false;
  }

  void clearAuthCache() => clearCache();

  /// Login with email/password → /api/token/ (DRF SimpleJWT)
  Future<TokenPair> login({
    required String email,
    required String password,
  }) async {
    final r = await _dio.post(
      '/token/',
      data: {'email': email, 'password': password},
    );

    if (r.statusCode == 200 && r.data is Map) {
      final m = r.data as Map;
      final access = m['access'] as String?;
      final refresh = m['refresh'] as String?;
      if (access == null) {
        throw Exception('No access token from server');
      }
      _access = access;
      _refresh = refresh;
      // set header for subsequent calls
      DioClient.instance.setTokens(access: access, refresh: refresh);
      return TokenPair(access: access, refresh: refresh);
    }
    throw Exception('Login failed (${r.statusCode})');
  }

  /// GET /api/auth/me/ → Me
  Future<Me> loadMe() async {
    final r = await _dio.get('/auth/me/');
    if (r.statusCode == 200 && r.data is Map) {
      _me = Me.fromJson(Map<String, dynamic>.from(r.data));
      return _me!;
    }
    throw Exception('Failed to load profile (${r.statusCode})');
  }

  /// Safe wrapper (returns Me or throws less)
  Future<Me?> loadMeSafe() async {
    try {
      return await loadMe();
    } catch (_) {
      return null;
    }
  }

  /// Called from DioClient when refresh succeeded
  Future<void> updateAccess(String newAccess) async {
    _access = newAccess;
    DioClient.instance.setTokens(access: newAccess, refresh: _refresh);
  }

  /// Called from DioClient when refresh failed
  Future<void> clearAuth() async {
    _access = null;
    _refresh = null;
    _me = null;
    DioClient.instance.clearTokens();
  }
}
