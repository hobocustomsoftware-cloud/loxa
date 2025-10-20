import 'dart:async';

import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import '../data/auth_repository.dart';
import '../models/me.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class AuthController extends ChangeNotifier {
  AuthController();

  final AuthRepository _repository = AuthRepository.instance;

  // NOTE: အရင်ကရှိနေတဲ့ _user, _isLoading state များကို ပင်မ me, _authBusy သို့ ပေါင်းစပ်လိုက်ပါသည်။

  Me? me;
  String? error;

  final _repo = AuthRepository.instance;

  bool _booted = false;
  bool _booting = false;
  bool _authBusy =
      false; // Login, Sign-in, Sign-out လုပ်ဆောင်နေချိန်ကို ကိုင်တွယ်ရန်

  bool get isReady => _booted;
  bool get isBooting => _booting;
  bool get busy => _authBusy || _booting; // Loading state အားလုံးကို စစ်ဆေးသည်

  bool get isLoggedIn => (_repo.accessToken ?? '').isNotEmpty;
  bool get isAuthenticated =>
      me != null; // Profile object (me) ရှိနေခြင်းကို စစ်ဆေးသည်

  // role flags (router guards use these)
  bool get isAdmin => me?.isAdmin ?? false;
  bool get isTeacher => me?.isTeacher ?? false;
  bool get isModerator => me?.isModerator ?? false;
  bool get isEditor => me?.isEditor ?? false;
  bool get isStudent => me?.isStudent ?? false;
  bool get isParent => me?.isParent ?? false;

  static const Duration _loginTimeout = Duration(seconds: 20);
  static const Duration _meTimeout = Duration(seconds: 15);

  Future<void> init() async {
    if (_booted) return;
    _booted = true;
    notifyListeners();
  }

  Future<void> boot() async {
    if (_booted || _booting) return;
    _booting = true;
    error = null;
    notifyListeners();

    try {
      // Repo.init() က SharedPreferences ကနေ token/me hydrate လုပ်ပြီး
      // Dio header sync ပါသွားတယ်
      await _repo.init();

      if (isLoggedIn) {
        // profile is already loaded in init(); just copy reference
        me = _repo.me;
      }
    } on TimeoutException {
      error = 'Profile request timed out.';
    } catch (e) {
      error = e.toString();
    } finally {
      _booted = true;
      _booting = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    if (_authBusy) return false;
    _authBusy = true;
    error = null;
    notifyListeners();

    try {
      await _repo
          .loginWithPassword(email: email, password: password)
          .timeout(_loginTimeout);

      // Repo has already saved tokens + set Dio header + fetched /me
      me = _repo.me;
      notifyListeners();
      return true;
    } on TimeoutException {
      error = 'Login timed out. Please check your connection and try again.';
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _authBusy = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------
  // Google Sign-In Method (INTEGRATED)
  // -----------------------------------------------------
  Future<bool> signInWithGoogle() async {
    debugPrint('[AuthController] signInWithGoogle() invoked');
    if (_authBusy) {
      debugPrint('[AuthController] Busy, ignoring signInWithGoogle');
      return false;
    }
    _authBusy = true;
    error = null;
    notifyListeners();
  
    try {
      debugPrint('[AuthController] Calling repo.signInWithGoogleFromMobile()');
      final meObj = await _repo.signInWithGoogleFromMobile().timeout(_loginTimeout);
      final ok = meObj != null;
      debugPrint('[AuthController] repo.signInWithGoogleFromMobile() returned: ' + (ok ? 'success' : 'null'));
  
      if (ok) {
        me = _repo.me;
        debugPrint('[AuthController] Updated me. me.email=' + (me?.email ?? 'null'));
        notifyListeners();
        return true;
      }
      return false;
    } on TimeoutException {
      error = 'Google Sign-In timed out. Please check your connection and try again.';
      debugPrint('[AuthController] Timeout in signInWithGoogle');
      return false;
    } catch (e, st) {
      error = e.toString();
      debugPrint('[AuthController] Exception during signInWithGoogle: ' + e.toString());
      debugPrint(st.toString());
      return false;
    } finally {
      _authBusy = false;
      debugPrint('[AuthController] authBusy reset to false');
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogleFromWeb(String accessToken) async {
    debugPrint('[AuthController] signInWithGoogleFromWeb(accessToken=***redacted***) invoked');
    if (_authBusy) {
      debugPrint('[AuthController] Busy, ignoring signInWithGoogleFromWeb');
      return false;
    }
    _authBusy = true;
    error = null;
    notifyListeners();
  
    try {
      debugPrint('[AuthController] Calling repo.signInWithGoogleAccessTokenWeb()');
      final meObj = await _repo
          .signInWithGoogleAccessTokenWeb(accessToken)
          .timeout(_loginTimeout);
      final ok = meObj != null;
      debugPrint('[AuthController] Web Google sign-in returned: ' + (ok ? 'success' : 'null'));
  
      if (ok) {
        me = _repo.me;
        debugPrint('[AuthController] Updated me after web sign-in. me.email=' + (me?.email ?? 'null'));
        notifyListeners();
        return true;
      }
      return false;
    } on TimeoutException {
      error = 'Google Sign-In timed out. Please check your connection and try again.';
      debugPrint('[AuthController] Timeout in signInWithGoogleFromWeb');
      return false;
    } catch (e, st) {
      error = e.toString();
      debugPrint('[AuthController] Exception during signInWithGoogleFromWeb: ' + e.toString());
      debugPrint(st.toString());
      return false;
    } finally {
      _authBusy = false;
      debugPrint('[AuthController] authBusy reset to false (web)');
      notifyListeners();
    }
  }

  // -----------------------------------------------------
  // Logout Method (Both Password and Social Sign Out)
  // -----------------------------------------------------
  Future<void> logout() async {
    if (_authBusy) return;
    _authBusy = true;
    notifyListeners();

    // Repo က Google Sign-Out နဲ့ Token Clear ကို တစ်ပြိုင်နက် လုပ်ဆောင်ရမည်။
    await _repo.logout();

    me = null;
    _authBusy = false;
    notifyListeners();
  }

  Future<bool> refreshProfile() async {
    try {
      final loaded = await _repo.fetchMe().timeout(_meTimeout);
      me = loaded;
      notifyListeners();
      return true;
    } on TimeoutException {
      error = 'Profile refresh timed out.';
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }
}
