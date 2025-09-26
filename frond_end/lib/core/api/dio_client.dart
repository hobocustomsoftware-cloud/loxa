// lib/core/api/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/data/auth_repository.dart';
import 'package:dio/browser.dart' as browser; // <-- for web cookies

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  static final base = kIsWeb
      ? 'http://localhost:8000/api/' // <- trailing slash ✅
      : 'http://10.0.2.2:8000/api/'; // <- trailing slash ✅

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  Dio get client => _dio;
  Dio get dio => _dio;

  bool _setupDone = false;

  void setupInterceptors() {
    if (_setupDone) return;
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final p = Uri.tryParse(options.path)?.path ?? options.path;
          final isAuth =
              p.startsWith('/auth/') ||
              p.startsWith('/token/') ||
              p.startsWith('/accounts/');
          if (!isAuth) {
            final access = AuthRepository.instance.accessToken;
            if (access?.isNotEmpty == true) {
              options.headers['Authorization'] = 'Bearer $access';
            }
          }
          return handler.next(options);
        },
        onError: (e, h) => h.next(e),
      ),
    );
    _setupDone = true;
  }

  void clearTokens() {
    _dio.options.headers.remove('Authorization');
    // _dio.options.headers.remove('x-refresh-token'); // ရှိရင်ပဲ
  }

  void setTokens({required String access, String? refresh}) {
    _dio.options.headers['Authorization'] = 'Bearer $access';
  }

  void clearAuth() {
    clearTokens();
  }
}
