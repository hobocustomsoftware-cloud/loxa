// utils/api_base.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiBase {
  static String resolve({String? lanIp}) {
    // lanIp: physical phone မှာ စမ်းချင်ရင် PC IP ထည့် (e.g. "192.168.1.50")
    if (kIsWeb) return 'http://localhost:8000/api/'; // Flutter Web on same PC
    if (Platform.isAndroid) {
      // AVD emulator
      return 'http://10.0.2.2:8000/api';
    }
    if (Platform.isIOS) return 'http://localhost:8000/api';
    if (lanIp != null && lanIp.isNotEmpty) {
      return 'http://$lanIp:8000/api'; // physical phone case
    }
    return 'http://localhost:8000/api';
  }
}
