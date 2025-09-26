// lib/features/auth/controllers/auth_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/api/dio_client.dart';
import '../data/auth_repository.dart';
import '../models/me.dart';

class AuthController extends ChangeNotifier {
  AuthController();

  // --- deps
  final _storage = const FlutterSecureStorage();
  final _repo = AuthRepository.instance;

  // --- auth state
  String? access;
  String? refresh;
  Me? me;
  String? error;

  // --- lifecycles / flags
  bool _booted = false;
  bool _booting = false;
  bool _authBusy = false;

  // --- public getters
  bool get isReady => _booted; // boot attempt finished (success or fail)
  bool get isBooting => _booting;
  bool get busy => _authBusy || _booting; // UI needs simple flag
  bool get isLoggedIn => (access?.isNotEmpty ?? false);

  bool get isAdmin {
    final m = me;
    if (m == null) return false;
    // rely only on server isAdmin + roles (NOT isStaff)
    return m.isAdmin ||
        m.roles.contains('admin') ||
        m.roles.contains('super_admin');
  }

  bool get isTeacher => me?.hasRole('teacher') ?? false;
  bool get isStudent => me?.hasRole('student') ?? false;
  bool get isParent => me?.hasRole('parent') ?? false;

  // abilities
  bool get canHostLive =>
      isAdmin || isTeacher || (me?.hasRole('moderator') ?? false);
  bool get canJoinLive =>
      isLoggedIn && (isStudent || isParent || isTeacher || isAdmin);

  // --- timeouts
  static const Duration _loginTimeout = Duration(seconds: 20);
  static const Duration _meTimeout = Duration(seconds: 15);

  /// App start → restore tokens → /me if token exists.
  /// Idempotent: second call returns immediately.
  Future<void> boot() async {
    if (_booted || _booting) return;
    _booting = true;
    error = null;
    notifyListeners();

    try {
      access = await _storage.read(key: 'access');
      refresh = await _storage.read(key: 'refresh');

      if (isLoggedIn) {
        // set tokens into Dio before hitting API
        DioClient.instance.setTokens(access: access!, refresh: refresh);

        // Load profile (safe)
        final loaded = await _repo.loadMeSafe().timeout(_meTimeout);
        if (loaded is Me) {
          me = loaded;
        } else {
          me = _repo.me; // if repo caches internally
        }
      }
    } on TimeoutException {
      error = 'Profile request timed out.';
    } catch (e) {
      error = e.toString();
      // (optional) If you want strict invalidation on boot failure:
      // await _purgeTokens(); // uncomment to force logout on boot error
    } finally {
      _booted = true;
      _booting = false;
      notifyListeners();
    }
  }

  /// Sign-in → get tokens → /me → expose isAdmin
  Future<bool> login({required String email, required String password}) async {
    if (_authBusy) return false; // prevent double taps
    _authBusy = true;
    error = null;
    notifyListeners();

    try {
      final pair = await _repo
          .login(email: email, password: password)
          .timeout(_loginTimeout);

      // persist tokens
      access = pair.access;
      refresh = pair.refresh;
      await _storage.write(key: 'access', value: access);
      await _storage.write(key: 'refresh', value: refresh);

      // attach to client
      DioClient.instance.setTokens(access: access!, refresh: refresh);

      // fetch profile
      final loaded = await _repo.loadMeSafe().timeout(_meTimeout);
      if (loaded is Me) {
        me = loaded;
      } else {
        me = _repo.me;
      }

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

  /// Clear tokens/profile and notify router guards to kick to /admin/signin
  Future<void> logout() async {
    await _purgeTokens();
    notifyListeners();
  }

  /// Optional helper: refresh only the profile
  Future<bool> refreshProfile() async {
    try {
      final loaded = await _repo.loadMeSafe().timeout(_meTimeout);
      if (loaded is Me) {
        me = loaded;
      } else {
        me = _repo.me;
      }
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

  /// Optional helper: clear error manually from UI
  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }

  // --- internal
  Future<void> _purgeTokens() async {
    try {
      await _storage.delete(key: 'access');
      await _storage.delete(key: 'refresh');
    } catch (_) {
      /* ignore */
    }

    // local controller state
    access = null;
    refresh = null;
    me = null;

    // ✅ Repo/Dio ကို high-level methods နဲ့သာ clear
    try {
      _repo.clearAuthCache(); // <-- implement below
      DioClient.instance.clearAuth();
    } catch (_) {
      /* ignore */
    }

    try {
      DioClient.instance.clearAuth(); // <-- implement below
    } catch (_) {
      /* ignore */
    }
  }
}
