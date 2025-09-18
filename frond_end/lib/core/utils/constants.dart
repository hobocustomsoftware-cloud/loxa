class Constants {
  // Android emulator → http://10.0.2.2:8000
  // iOS simulator → http://127.0.0.1:8000
  // Device on LAN → http://<your-ip>:8000
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8000/api',
  );

  static const courses = '/courses/';
  static const sessions = '/sessions/';
  static const seats = '/seats/';
  static const attendance = '/attendance/';
  static const modules = '/modules/';
  static const lessons = '/lessons/';
  static const assets = '/assets/';
  static const agoraToken = '/agora/token/';

  // Djoser/SimpleJWT defaults — change if customized
  static const jwtCreate = '/auth/jwt/create/';
  static const jwtRefresh = '/auth/jwt/refresh/';

  // org id you want to browse as (anonymous browse OK but needs this header)
  static const defaultOrgId = '1';
}

// class Constants {
//   // Backend base URL
//   static const String apiBase = 'http://localhost:8000';

//   // Endpoints
//   static const String courses = '/api/courses/';
//   static const String modules = '/api/modules/';
//   static const String lessons = '/api/lessons/';
//   static const String assets  = '/api/assets/';

//   // Auth (ရှိရင်သုံး)
//   static const String jwtRefresh = '/api/token/refresh/';
// }
