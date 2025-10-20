import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/dio_client.dart';
import '../../../core/utils/constants.dart';
import '../models/me.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final Dio _dio = DioClient.instance.dio;

  // 🛑 Google Sign In Configuration (Production Ready)
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
    // 1. Web Client ID (Frontend/Web/Django Admin Base ID)
    clientId:
        '676531831869-shs6inbdguae7ijmafs4ne98vp6s5vp1.apps.googleusercontent.com',

    // 2. Server Client ID (Mobile App အတွက် Production Client ID)
    // ✅ FIX: serverClientId is not needed for web. Use null or an empty string.
    serverClientId: kIsWeb
        ? '676531831869-shs6inbdguae7ijmafs4ne98vp6s5vp1.apps.googleusercontent.com'
        : '676531831869-d23gl5i5f7qpra4et7bd077nkc2klmab.apps.googleusercontent.com',
  );

  String? _access;
  String? _refresh;
  Me? _me;

  String? get accessToken => _access;
  String? get refreshToken => _refresh;
  Me? get me => _me;

  static const _kAccess = 'auth.access';
  static const _kRefresh = 'auth.refresh';
  static const _kMe = 'auth.me';

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _access = sp.getString(_kAccess);
    _refresh = sp.getString(_kRefresh);
    final meStr = sp.getString(_kMe);
    if (meStr != null) {
      try {
        _me = Me.fromJson(jsonDecode(meStr) as Map<String, dynamic>);
      } catch (_) {}
    }
    if (_access != null && _access!.isNotEmpty) {
      DioClient.instance.setTokens(access: _access!);
      try {
        // If fetching the user fails (e.g., token expired), it will be caught.
        await fetchMe();
      } catch (e) {
        debugPrint('Failed to fetch user on init: $e');
      }
    }
  }

  Future<void> saveTokens(String access, {String? refresh}) async {
    final sp = await SharedPreferences.getInstance();
    _access = access;
    if (refresh != null) _refresh = refresh;
    await sp.setString(_kAccess, _access!);
    if (_refresh != null) await sp.setString(_kRefresh, _refresh!);
    DioClient.instance.setTokens(access: _access!);
  }

  Future<void> updateAccess(String newAccess) async => saveTokens(newAccess);

  Future<void> clearAuthCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kAccess);
    await sp.remove(_kRefresh);
    await sp.remove(_kMe);
    _access = null;
    _refresh = null;
    _me = null;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await clearAuthCache();
    DioClient.instance.clearAuth();
  }

  // User profile အပြည့်အစုံကို /me/ endpoint မှတစ်ဆင့်သာ ရယူရန် ပြင်ဆင်ထားသည်။
  Future<Me> fetchMe() async {
    try {
      debugPrint('[AuthRepository] GET /me/ start');
      final r = await _dio.get('/me/');
      debugPrint('[AuthRepository] GET /me/ status=' + (r.statusCode?.toString() ?? 'null'));
      if (r.statusCode == 200 && r.data is Map) {
        _me = Me.fromJson((r.data as Map).cast<String, dynamic>());
        final sp = await SharedPreferences.getInstance();
        await sp.setString(_kMe, jsonEncode(r.data));
        debugPrint('[AuthRepository] /me/ parsed ok, me.email=' + (_me?.email ?? 'null'));
        return _me!;
      }
      throw Exception('Failed to load user profile. Status: ${r.statusCode}');
    } catch (e) {
      debugPrint('[AuthRepository] Error fetching /me/: ' + e.toString());
      throw Exception('Failed to load user profile (/me/): $e');
    }
  }

  Future<void> loginWithPassword({
    required String email,
    required String password,
  }) async {
    final r = await _dio.post(
      '${Constants.jwtCreate}', // /token/
      data: {'email': email, 'password': password},
    );
    if (r.statusCode == 200 && r.data is Map) {
      final m = (r.data as Map).cast<String, dynamic>();
      final access = (m['access'] as String?) ?? '';
      final refresh = m['refresh'] as String?;
      if (access.isEmpty) throw Exception('No access token');
      await saveTokens(access, refresh: refresh);
      await fetchMe();
      return;
    }
    // ✅ IMPROVEMENT: More descriptive error.
    throw Exception('Login failed: ${r.statusCode} - ${r.data}');
  }

  // ... (migrateLegacyKeys, devDangerWipeAllLocal စတဲ့ methods များ မပြောင်းလဲပါ) ...

  // -----------------------------------------------------
  // Google Sign In Method (Final Path Fix)
  // -----------------------------------------------------
  Future<Me?> signInWithGoogleFromMobile() async {
    try {
      debugPrint('[AuthRepository] Mobile Google sign-in start');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      debugPrint('[AuthRepository] Mobile Google sign-in user=' + (googleUser?.email ?? 'null'));
      if (googleUser == null) {
        debugPrint('[AuthRepository] Mobile Google sign-in cancelled by user');
        return null;
      }
      return await _processGoogleSignIn(googleUser);
    } catch (e) {
      debugPrint('[AuthRepository] Google Sign In Error (mobile): ' + e.toString());
      await _googleSignIn.signOut();
      return null;
    }
  }

  /// Processes the Google sign-in account, sends the token to the backend,
  /// and fetches the user profile. This can be used by both mobile and web flows.
  Future<Me?> _processGoogleSignIn(GoogleSignInAccount googleUser) async {
    try {
      debugPrint('[AuthRepository] Processing Google account=' + (googleUser.email));
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? token = kIsWeb
          ? googleAuth.accessToken
          : googleAuth.idToken;

      debugPrint('[AuthRepository] Token resolved. isWeb=' + kIsWeb.toString() + ', hasToken=' + ((token ?? '').isNotEmpty).toString());

      if (token == null) {
        throw Exception('Failed to get Google ID Token.');
      }

      debugPrint('[AuthRepository] Sending token to backend...');
      final r = await _dio.post(
        '${Constants.googleLoginToken}',
        data: {'access_token': token},
      );
      debugPrint('[AuthRepository] Backend response status=' + (r.statusCode?.toString() ?? 'null'));

      if (r.statusCode == 200 && r.data is Map) {
        final m = (r.data as Map).cast<String, dynamic>();
        final access = (m['access'] as String?) ?? (m['key'] as String?) ?? '';
        final refresh = (m['refresh'] as String?);

        if (access.isEmpty) {
          throw Exception(
            'Backend did not return access token. Response: ${r.data}',
          );
        }

        debugPrint('[AuthRepository] Saving tokens and fetching profile');
        await saveTokens(access, refresh: refresh);
        return await fetchMe();
      }

      throw Exception(
        'Google Auth failed at backend. Status: ${r.statusCode}, Message: ${r.statusMessage}, Data: ${r.data}',
      );
    } catch (e) {
      debugPrint('[AuthRepository] Process Google Sign-In error: ' + e.toString());
      await _googleSignIn.signOut();
      throw Exception('Failed to process Google Sign-In: $e');
    }
  }

  /// This method is now specifically for the web, to be called after
  /// the Google button has returned a user.
  Future<Me?> signInWithGoogleFromWeb(GoogleSignInAccount googleUser) async {
    debugPrint('[AuthRepository] Web flow using GoogleSignInAccount');
    return await _processGoogleSignIn(googleUser);
  }

  Future<Me?> signInWithGoogleAccessTokenWeb(String accessToken) async {
    try {
      debugPrint('[AuthRepository] signInWithGoogleAccessTokenWeb start');
      if ((accessToken).isEmpty) {
        throw Exception('Empty access token');
      }
  
      debugPrint('[AuthRepository] Posting access token to backend');
      final r = await _dio.post(
        '${Constants.googleLoginToken}',
        data: {'access_token': accessToken},
      );
      debugPrint('[AuthRepository] Backend response status=' + (r.statusCode?.toString() ?? 'null'));
  
      if (r.statusCode == 200 && r.data is Map) {
        final m = (r.data as Map).cast<String, dynamic>();
        final access = (m['access'] as String?) ?? (m['key'] as String?) ?? '';
        final refresh = (m['refresh'] as String?);
        if (access.isEmpty) {
          throw Exception('Backend did not return access token. Response: ${r.data}');
        }
  
        await saveTokens(access, refresh: refresh);
        debugPrint('[AuthRepository] Tokens saved. Fetching /me/');
        return await fetchMe();
      }
  
      throw Exception('Google Auth failed at backend. Status: ${r.statusCode}, Message: ${r.statusMessage}, Data: ${r.data}');
    } catch (e) {
      debugPrint('[AuthRepository] signInWithGoogleAccessTokenWeb error: ' + e.toString());
      try { await _googleSignIn.signOut(); } catch (_) {}
      throw Exception('Failed to process Google Sign-In (web token): $e');
    }
  }
}
