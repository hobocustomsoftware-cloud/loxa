// import 'dart:math';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import '../../../core/api/dio_client.dart';
// import '../data/live_api.dart'; // your existing Dio wrapper

// class ClientLivePage extends StatefulWidget {
//   final String channelId; // e.g. courseId/classId
//   final ClientRoleType initialRole; // Host or Audience
//   const ClientLivePage({
//     super.key,
//     required this.channelId,
//     this.initialRole = ClientRoleType.clientRoleAudience,
//   });

//   @override
//   State<ClientLivePage> createState() => _ClientLivePageState();
// }

// class _ClientLivePageState extends State<ClientLivePage> {
//   final _api = LiveApi();
//   final int _sessionId = 123;
//   late final RtcEngine _engine = createAgoraRtcEngine();
//   bool _engineReady = false;
//   bool _joined = false;
//   bool _joining = false;

//   ClientRoleType _role = ClientRoleType.clientRoleAudience;
//   final int _uid = Random().nextInt(1 << 31);
//   final List<int> _remoteUids = [];

//   bool _micOn = true;
//   bool _camOn = true;
//   bool _front = true;

//   @override
//   void initState() {
//     super.initState();
//     _role = widget.initialRole;
//     _init();
//   }

//   @override
//   void dispose() {
//     _leave();
//     _engine.release();
//     super.dispose();
//   }

//   Future<void> _init() async {
//     // App ID ကို env/app config မှထည့်ပါ (dev အထိ အောက်လို string ထည့်လို့ကောင်း)
//     const appId = String.fromEnvironment('AGORA_APP_ID', defaultValue: '');
//     if (appId.isEmpty) {
//       debugPrint('AGORA_APP_ID missing – set via --dart-define or config');
//     }
//     await _engine.initialize(
//       RtcEngineContext(
//         appId: appId,
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//       ),
//     );

//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (conn, elapsed) => setState(() => _joined = true),
//         onLeaveChannel: (conn, stats) => setState(() {
//           _joined = false;
//           _remoteUids.clear();
//         }),
//         onUserJoined: (conn, uid, elapsed) =>
//             setState(() => _remoteUids.add(uid)),
//         onUserOffline: (conn, uid, reason) =>
//             setState(() => _remoteUids.remove(uid)),
//         onError: (code, msg) => _snack('Agora error: $code $msg'),
//       ),
//     );

//     await _engine.enableVideo();
//     setState(() => _engineReady = true);
//     _join(); // auto-join
//   }

//   Future<String> _fetchToken(String channel, int uid) async {
//     // 🔐 Production: backend server ကို သုံးပါ
//     // Example endpoint: GET /agora/token?channel=...&uid=...
//     try {
//       final res = await DioClient.instance.client.get(
//         '/agora/token',
//         queryParameters: {
//           'channel': channel,
//           'uid': uid,
//           'role': _role == ClientRoleType.clientRoleBroadcaster
//               ? 'publisher'
//               : 'audience',
//         },
//       );
//       final token = (res.data is Map) ? (res.data['token'] as String?) : null;
//       return token ?? '';
//     } catch (e) {
//       // Dev fallback: empty token (project setting “no certificate” only)
//       debugPrint('Token fetch failed: $e');
//       return '';
//     }
//   }

//   Future<void> _join() async {
//     if (_joining || _joined) return;

//     setState(() => _joining = true);
//     try {
//       await _ensurePermissions();
//       await _initEngine(); // initialize with your AGORA_APP_ID (dart-define or const)

//       final asHost = _role == ClientRoleType.clientRoleBroadcaster;

//       // 1) Attendance
//       await _api.join(_sessionId);

//       // 2) RTC token
//       final tok = await _api.token(_sessionId, asHost: asHost);

//       // 3) Join Agora
//       await _engine.setClientRole(role: _role);
//       if (asHost) await _engine.startPreview();

//       await _engine.joinChannel(
//         token: tok.token, // '' allowed if no-certificate project (dev only)
//         channelId: tok.channel,
//         uid: tok.uid,
//         options: ChannelMediaOptions(
//           channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//           clientRoleType: _role,
//           publishCameraTrack: asHost,
//           publishMicrophoneTrack: asHost,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _joining = false);
//     }
//   }

//   Future<void> _leave() async {
//     try {
//       await _engine.leaveChannel();
//       await _engine.stopPreview();
//     } catch (_) {}
//   }

//   void _snack(String m) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         children: [
//           // Header / Role Switch
//           Row(
//             children: [
//               Text(
//                 'Channel: ${widget.channelId}',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               const SizedBox(width: 12),
//               SegmentedButton<ClientRoleType>(
//                 segments: const [
//                   ButtonSegment(
//                     value: ClientRoleType.clientRoleBroadcaster,
//                     label: Text('Host'),
//                   ),
//                   ButtonSegment(
//                     value: ClientRoleType.clientRoleAudience,
//                     label: Text('Audience'),
//                   ),
//                 ],
//                 selected: {_role},
//                 onSelectionChanged: (s) async {
//                   final newRole = s.first;
//                   if (newRole == _role) return;
//                   setState(() => _role = newRole);
//                   if (_joined) {
//                     // switch role live
//                     await _engine.setClientRole(role: _role);
//                     if (_role == ClientRoleType.clientRoleBroadcaster) {
//                       await _engine.startPreview();
//                     } else {
//                       await _engine.stopPreview();
//                     }
//                   }
//                 },
//               ),
//               const Spacer(),
//               FilledButton.icon(
//                 onPressed: _joined ? null : _join,
//                 icon: _joining
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.play_arrow),
//                 label: Text(_joined ? 'Joined' : 'Join'),
//               ),
//               const SizedBox(width: 8),
//               OutlinedButton.icon(
//                 onPressed: _joined ? _leave : null,
//                 icon: const Icon(Icons.stop),
//                 label: const Text('Leave'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Video grid (left=local/host preview, right=first remote)
//           Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Card(
//                     elevation: 0,
//                     child:
//                         _role == ClientRoleType.clientRoleBroadcaster && _joined
//                         ? AgoraVideoView(
//                             controller: VideoViewController(
//                               rtcEngine: _engine,
//                               canvas: const VideoCanvas(uid: 0), // local
//                             ),
//                           )
//                         : Center(
//                             child: Text(
//                               _joined ? 'Audience Mode' : 'Not joined',
//                               style: TextStyle(color: cs.outline),
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Card(
//                     elevation: 0,
//                     child: _remoteUids.isEmpty
//                         ? Center(
//                             child: Text(
//                               'Waiting for remote…',
//                               style: TextStyle(color: cs.outline),
//                             ),
//                           )
//                         : AgoraVideoView(
//                             controller: VideoViewController.remote(
//                               rtcEngine: _engine,
//                               connection: RtcConnection(
//                                 channelId: widget.channelId,
//                               ),
//                               canvas: VideoCanvas(uid: _remoteUids.first),
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Controls (host only)
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               FilledButton.tonalIcon(
//                 onPressed:
//                     _joined && _role == ClientRoleType.clientRoleBroadcaster
//                     ? () async {
//                         _micOn = !_micOn;
//                         await _engine.muteLocalAudioStream(!_micOn);
//                         setState(() {});
//                       }
//                     : null,
//                 icon: Icon(_micOn ? Icons.mic : Icons.mic_off),
//                 label: Text(_micOn ? 'Mic On' : 'Mic Off'),
//               ),
//               const SizedBox(width: 8),
//               FilledButton.tonalIcon(
//                 onPressed:
//                     _joined && _role == ClientRoleType.clientRoleBroadcaster
//                     ? () async {
//                         _camOn = !_camOn;
//                         await _engine.muteLocalVideoStream(!_camOn);
//                         setState(() {});
//                       }
//                     : null,
//                 icon: Icon(_camOn ? Icons.videocam : Icons.videocam_off),
//                 label: Text(_camOn ? 'Cam On' : 'Cam Off'),
//               ),
//               const SizedBox(width: 8),
//               OutlinedButton.icon(
//                 onPressed:
//                     _joined && _role == ClientRoleType.clientRoleBroadcaster
//                     ? () async {
//                         _front = !_front;
//                         await _engine.switchCamera();
//                         setState(() {});
//                       }
//                     : null,
//                 icon: const Icon(Icons.flip_camera_android),
//                 label: const Text('Flip'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
