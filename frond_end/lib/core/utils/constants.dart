class Constants {
  // Android emulator → http://10.0.2.2:8000
  // iOS simulator → http://127.0.0.1:8000
  // Device on LAN → http://<your-ip>:8000
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    // defaultValue: 'http://localhost:8000/api',
    defaultValue: 'https://lms.ai1.com.mm/api',
  );

  static const courses = '/courses/';
  static const sessions = '/sessions/';
  static const seats = '/seats/';
  static const attendance = '/attendance/';
  static const modules = '/modules/';
  static const lessons = '/lessons/';
  static const assets = '/assets/';
  static const agoraToken = '/agora/token/';

  static const userDetail = '/me/';

  static const googleAuth = '/auth/google/';

  static const jwtCreate = '/auth/login/';

  static const jwtRefresh = '/token/refresh/';

  static const loginToken = '/auth/login/';

  static const tokenRefresh = '/token/refresh/';

  static const googleLogin = '/auth/google/';

  static const fetchUserDetail = '/me/';

  static const googleLoginToken = '/web-auth/google/login/token/';

  // org id you want to browse as (anonymous browse OK but needs this header)
  static const defaultOrgId = '1';
}
