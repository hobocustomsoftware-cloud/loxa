// import 'dart:math';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// import '../../../../../core/api/dio_client.dart';
// import '../../../../live/data/live_api.dart';

// class AdminLiveTestPage extends StatefulWidget {
//   const AdminLiveTestPage({super.key});
//   @override
//   State<AdminLiveTestPage> createState() => _AdminLiveTestPageState();
// }

// class _AdminLiveTestPageState extends State<AdminLiveTestPage> {
//   final _api = LiveApi();
//   final int _sessionId = 123;

//   final _appIdCtl = TextEditingController(text: '');
//   final _channelCtl = TextEditingController(text: 'test_channel');
//   final _tokenCtl = TextEditingController(
//     text: '',
//   ); // optional if your project allows

//   late final RtcEngine _engine = createAgoraRtcEngine();
//   bool _engineInited = false;
//   bool _joining = false;
//   bool _joined = false;

//   // Host (Broadcaster) or Audience
//   ClientRoleType _role = ClientRoleType.clientRoleBroadcaster;

//   // Remote user list (we’ll display first one)
//   final List<int> _remoteUids = [];
//   final int _localUid = Random().nextInt(1 << 31);

//   @override
//   void dispose() {
//     _appIdCtl.dispose();
//     _channelCtl.dispose();
//     _tokenCtl.dispose();
//     _leaveAndDispose();
//     super.dispose();
//   }

//   Future<void> _ensurePermissions() async {
//     if (!kIsWeb) {
//       await [Permission.camera, Permission.microphone].request();
//     }
//   }

//   Future<void> _initEngine() async {
//     if (_engineInited) return;
//     await _engine.initialize(
//       RtcEngineContext(
//         appId: _appIdCtl.text.trim(),
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//       ),
//     );

//     // Events
//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection conn, int elapsed) {
//           setState(() => _joined = true);
//         },
//         onUserJoined: (RtcConnection conn, int remoteUid, int elapsed) {
//           setState(() => _remoteUids.add(remoteUid));
//         },
//         onUserOffline:
//             (RtcConnection conn, int remoteUid, UserOfflineReasonType reason) {
//               setState(() => _remoteUids.remove(remoteUid));
//             },
//         onLeaveChannel: (RtcConnection conn, RtcStats stats) {
//           setState(() {
//             _joined = false;
//             _remoteUids.clear();
//           });
//         },
//         onError: (ErrorCodeType code, String msg) {
//           if (mounted) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text('Agora error: $code $msg')));
//           }
//         },
//       ),
//     );

//     await _engine.enableVideo();
//     _engineInited = true;
//   }

//   String _tokenOrEmpty() {
//     final t = _tokenCtl.text.trim();
//     return t.isEmpty ? '' : t;
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

//   Future<void> _leaveAndDispose() async {
//     try {
//       if (_engineInited) {
//         await _engine.leaveChannel();
//         await _engine.stopPreview();
//         await _engine.release();
//       }
//     } catch (_) {}
//   }

//   Future<void> _leave() async {
//     try {
//       await _engine.leaveChannel();
//       await _engine.stopPreview();
//     } catch (_) {}
//   }

//   Future<String> fetchAgoraToken({
//     required String channel,
//     required int uid,
//     required ClientRoleType role,
//   }) async {
//     final dio = DioClient
//         .instance
//         .client; // သင့် wrapper အမည်ကိုက်အောင် ('client' or 'dio')
//     final roleStr = role == ClientRoleType.clientRoleBroadcaster
//         ? 'publisher'
//         : 'audience';
//     final res = await dio.get(
//       '/agora/token',
//       queryParameters: {'channel': channel, 'uid': uid, 'role': roleStr},
//     );
//     final data = res.data;
//     return (data is Map && data['token'] is String)
//         ? data['token'] as String
//         : '';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Controls
//           Card(
//             elevation: 0,
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _appIdCtl,
//                           decoration: const InputDecoration(
//                             labelText: 'Agora App ID',
//                             border: OutlineInputBorder(),
//                             isDense: true,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextField(
//                           controller: _channelCtl,
//                           decoration: const InputDecoration(
//                             labelText: 'Channel ID',
//                             border: OutlineInputBorder(),
//                             isDense: true,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextField(
//                           controller: _tokenCtl,
//                           decoration: const InputDecoration(
//                             labelText: 'Temp Token (optional)',
//                             border: OutlineInputBorder(),
//                             isDense: true,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       SegmentedButton<ClientRoleType>(
//                         segments: const [
//                           ButtonSegment(
//                             value: ClientRoleType.clientRoleBroadcaster,
//                             label: Text('Host'),
//                           ),
//                           ButtonSegment(
//                             value: ClientRoleType.clientRoleAudience,
//                             label: Text('Audience'),
//                           ),
//                         ],
//                         selected: {_role},
//                         onSelectionChanged: (s) =>
//                             setState(() => _role = s.first),
//                       ),
//                       const Spacer(),
//                       FilledButton.icon(
//                         onPressed: _joined ? null : _join,
//                         icon: _joining
//                             ? const SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Icon(Icons.play_arrow),
//                         label: Text(_joined ? 'Joined' : 'Join'),
//                       ),
//                       const SizedBox(width: 8),
//                       OutlinedButton.icon(
//                         onPressed: _joined ? _leave : null,
//                         icon: const Icon(Icons.stop),
//                         label: const Text('Leave'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // Video area
//           Expanded(
//             child: Row(
//               children: [
//                 // Local (Host preview / Audience shows nothing)
//                 Expanded(
//                   child: Card(
//                     elevation: 0,
//                     child:
//                         _joined && _role == ClientRoleType.clientRoleBroadcaster
//                         ? AgoraVideoView(
//                             controller: VideoViewController(
//                               rtcEngine: _engine,
//                               canvas: const VideoCanvas(uid: 0),
//                             ),
//                           )
//                         : Center(
//                             child: Text(
//                               _role == ClientRoleType.clientRoleBroadcaster
//                                   ? 'Local Preview'
//                                   : 'Audience Mode',
//                               style: TextStyle(color: cs.outline),
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // First remote
//                 Expanded(
//                   child: Card(
//                     elevation: 0,
//                     child: _remoteUids.isEmpty
//                         ? Center(
//                             child: Text(
//                               'Waiting for remote user…',
//                               style: TextStyle(color: cs.outline),
//                             ),
//                           )
//                         : AgoraVideoView(
//                             controller: VideoViewController.remote(
//                               rtcEngine: _engine,
//                               connection: RtcConnection(
//                                 channelId: _channelCtl.text.trim(),
//                               ),
//                               canvas: VideoCanvas(uid: _remoteUids.first),
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
