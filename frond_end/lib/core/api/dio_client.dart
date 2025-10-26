// lib/core/api/dio_client.dart
import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../../features/auth/data/auth_repository.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  /// Production server URL ကို အသုံးပြုရန် ပြင်ဆင်ထားသည်။
  static String getBaseUrl() {
    // return 'http://localhost:8000/api/';
    return 'https://lms2.ai1.com.mm/api/';
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: getBaseUrl(),
      connectTimeout: const Duration(
        seconds: 30,
      ), // ⬅️ Timeout ကို စက္ကန့် ၃၀ သို့ တိုးမြှင့်ထားသည်
      receiveTimeout: const Duration(
        seconds: 30,
      ), // ⬅️ Timeout ကို စက္ကန့် ၃၀ သို့ တိုးမြှင့်ထားသည်
      // 5xx ကိုပဲ Dio error ထုတ်မယ် (CORS preflight 204/3xx/4xx မပဲ)
      validateStatus: (s) => s != null && s < 500,
      headers: {'Accept': 'application/json'},
      followRedirects: true,
    ),
  );

  Dio get dio => _dio;

  bool _setupDone = false;

  void setupInterceptors() {
    if (_setupDone) return;

    // Hot restart နဲ့ duplicate interceptors မဖြစ်အောင်
    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // ✅ အမြဲ Authorization header ထည့် (login/token route တွေကို ဒီနေရာက special-case မလို)
            final t = AuthRepository.instance.accessToken;
            if (t != null && t.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $t';
            }
            options.headers['Accept'] = 'application/json';

            // ❗ IMPORTANT: baseUrl သုံးနေရင် path ကို leading slash မထားပါ
            // e.g. 'live-sessions/' ✔,  '/live-sessions/' ✖ (baseUrl ရဲ့ '/api' ပြတ်သွားနိုင်)
            // 🔧 Normalize: strip any leading slash to preserve baseUrl path
            if (options.path.startsWith('/')) {
              options.path = options.path.replaceFirst(RegExp(r'^/+'), '');
            }
          } catch (e, st) {
            debugPrint('⚠️ Dio onRequest inject error: $e\n$st');
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          debugPrint(
            '❌ Dio ${e.requestOptions.method} ${e.requestOptions.uri} -> ${e.response?.statusCode} (${e.message})',
          );
          return handler.next(e);
        },
      ),
    );

    _setupDone = true;
  }

  void setTokens({required String access, String? refresh}) {
    _dio.options.headers['Authorization'] = 'Bearer $access';
  }

  void clearTokens() {
    _dio.options.headers.remove('Authorization');
  }

  void clearAuth() => clearTokens();
}
