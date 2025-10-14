// utils/api_base.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiBase {
  static String resolve({String? lanIp}) {
    // 🚨 FIX: Base URL ရဲ့ အဆုံးမှာ Trailing Slash ကို ဖယ်လိုက်ပါ။
    const String productionBase = 'http://localhost:8000/pi'; // ⬅️ / မပါတော့ပါ

    if (kIsWeb) return productionBase; // Flutter Web on same PC
    if (Platform.isAndroid) {
      // AVD emulator
      // 💡 Android Emulator အတွက် Local IP (http://10.0.2.2:8000) ကို သုံးတာ ပိုကောင်းပါတယ်
      return productionBase;
    }
    if (Platform.isIOS) return productionBase;
    if (lanIp != null && lanIp.isNotEmpty) {
      return 'https://$lanIp/api'; // physical phone case
    }
    return productionBase;
  }
}
