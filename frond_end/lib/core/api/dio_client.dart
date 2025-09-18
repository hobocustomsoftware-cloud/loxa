import 'package:dio/dio.dart';
import '../utils/constants.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: Constants.apiBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  String? _access;
  String? _refresh;
  String? _orgId;

  void setTokens({required String access, String? refresh}) {
    _access = access;
    _refresh = refresh;
  }

  void setOrgId(String? orgId) => _orgId = orgId;

  void setupInterceptors() {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (req, h) {
          if (_access?.isNotEmpty == true) {
            req.headers['Authorization'] = 'Bearer $_access';
          }
          // Dev/test အတွက် org header ထည့်ထားမှ backend 403 မပေးနိုင်
          if (_orgId?.isNotEmpty == true) {
            req.headers['X-Org-ID'] = _orgId;
          } else {
            req.headers['X-Org-ID'] = '1'; // fallback
          }
          h.next(req);
        },
        onError: (err, h) async {
          if (err.response?.statusCode == 401 && _refresh?.isNotEmpty == true) {
            try {
              final r = await dio.post(
                Constants.jwtRefresh,
                data: {'refresh': _refresh},
              );
              final newAccess = r.data['access'] as String?;
              if (newAccess != null && newAccess.isNotEmpty) {
                _access = newAccess;
                err.requestOptions.headers['Authorization'] =
                    'Bearer $newAccess';
                if (_orgId?.isNotEmpty == true) {
                  err.requestOptions.headers['X-Org-ID'] = _orgId!;
                }
                final clone = await dio.fetch(err.requestOptions);
                return h.resolve(clone);
              }
            } catch (_) {}
          }
          h.next(err);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchAgoraToken(
    int sessionId,
    String role,
  ) async {
    final r = await DioClient.instance.dio.post(
      '/agora/token/',
      data: {
        "session_id": sessionId,
        "role": role, // "publisher" or "subscriber"
      },
    );
    return r.data as Map<String, dynamic>;
  }
}

// // core/api/dio_client.dart
// import 'package:dio/dio.dart';

// class DioClient {
//   DioClient._();
//   static final instance = DioClient._();

//   final dio = Dio(
//     BaseOptions(
//       baseUrl: 'http://localhost:8000/api/',
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 20),
//       validateStatus: (s) =>
//           s != null && s < 500, // let 4xx fall through to app
//     ),
//   );

//   // set this from your app (settings/login/org switcher)
//   int? _orgId; // null => public

//   void setOrgId(int? id) {
//     _orgId = id;
//   }

//   void setupInterceptors() {
//     dio.interceptors.clear();
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           options.headers.remove('X-Org-ID');
//           if (_orgId != null && _orgId! > 0) {
//             options.headers['X-Org-ID'] = _orgId.toString();
//           }
//           return handler.next(options);
//         },
//         onError: (e, handler) {
//           // debug: print server body to see exact 403 reason
//           // ignore: avoid_print
//           print('HTTP ${e.response?.statusCode} -> ${e.response?.data}');
//           return handler.next(e);
//         },
//       ),
//     );
//   }
// }
