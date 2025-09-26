// lib/core/config/agora_config.dart

/// Centralized Agora configuration for Flutter.
///
/// How to inject your App ID at run/build time:
///   flutter run -d chrome --dart-define=AGORA_APP_ID=YOUR_APP_ID
///   flutter run --dart-define=AGORA_APP_ID=YOUR_APP_ID
///   flutter build apk --dart-define=AGORA_APP_ID=YOUR_APP_ID
///
/// In production, prefer passing via --dart-define or letting the backend
/// `/rtc-token` endpoint include `app_id` — then call [resolveAppId].
library agora_config;

/// Compile-time App ID (from --dart-define). Keep default empty for safety.
const kAgoraAppId = String.fromEnvironment(
  'AGORA_APP_ID',
  defaultValue: '', // ❗️Do NOT hardcode real secrets here.
);

/// True if a compile-time App ID was provided.
bool get hasAgoraAppId => kAgoraAppId.isNotEmpty;

/// Resolve the App ID to use:
/// - If the backend provided an `app_id`, prefer that.
/// - Otherwise fall back to the compile-time value [kAgoraAppId].
String resolveAppId({String? fromServer}) {
  final server = (fromServer ?? '').trim();
  if (server.isNotEmpty) return server;
  return kAgoraAppId;
}

/// Optional guard (debug assert). Call before initializing Agora.
void assertHasAppId(String? appId) {
  assert(
    (appId ?? '').isNotEmpty,
    'Agora App ID is missing. '
    'Pass --dart-define=AGORA_APP_ID=YOUR_APP_ID or return `app_id` from /rtc-token.',
  );
}
