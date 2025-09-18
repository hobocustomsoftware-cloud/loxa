import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api/dio_client.dart';
import '../../core/utils/constants.dart';

class AuthController extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? access;
  String? refresh;
  bool loading = false;
  String? error;

  Future<void> login({required String email, required String password}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = await DioClient.instance.dio.post(
        Constants.jwtCreate,
        data: {'email': email, 'password': password},
      );
      access = r.data['access'];
      refresh = r.data['refresh'];
      await _storage.write(key: 'access', value: access);
      await _storage.write(key: 'refresh', value: refresh);
      DioClient.instance.setTokens(access: access!, refresh: refresh);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    access = null;
    refresh = null;
    await _storage.deleteAll();
    // DioClient.instance.clearTokens();
    notifyListeners();
  }

  Future<void> tryRestore() async {
    access = await _storage.read(key: 'access');
    refresh = await _storage.read(key: 'refresh');
    if (access != null) {
      DioClient.instance.setTokens(access: access!, refresh: refresh);
    }
    notifyListeners();
  }
}
