// lib/features/live/ui/live_session_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../data/live_repository.dart';
import '../models/live_session_model.dart';

class LiveSessionPage extends StatefulWidget {
  final int sessionId;
  const LiveSessionPage({super.key, required this.sessionId});

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  final _repo = LiveRepository();

  RtcEngine? _engine;
  LiveSession? _session;
  String? _err;
  bool _loading = true;

  bool _joined = false;
  int? _localUid;
  final Set<int> _remoteUids = {};

  bool _micOn = true;
  bool _camOn = true;
  bool _speakerOn = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      // 1) Camera + Mic Permission
      await _ensurePermissions();

      // 2) Load session meta
      final s = await _repo.getSession(widget.sessionId);

      // 3) Mark attendance (join)
      await _repo.join(widget.sessionId);

      // 4) Request Agora Token
      final token = await _repo.getAgoraToken(
        channel: s.channelName,
        role: 'publisher',
      );

      // 5) Init Agora Engine
      final engine = createAgoraRtcEngine();
      await engine.initialize(
        const RtcEngineContext(appId: 'YOUR_AGORA_APP_ID'),
      );

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            setState(() {
              _joined = true;
              _localUid =
                  connection.localUid; // ✅ v6.x မှာ connection ထဲကနေ UID ယူရမယ်
            });
          },

          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            setState(() => _remoteUids.add(remoteUid));
          },
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
                setState(() => _remoteUids.remove(remoteUid));
              },
        ),
      );

      await engine.enableVideo();
      await engine.enableAudio();
      await engine.setEnableSpeakerphone(_speakerOn);

      await engine.startPreview();
      await engine.joinChannel(
        token: token.rtcToken,
        channelId: s.channelName,
        uid: int.tryParse(token.uid) ?? 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      setState(() {
        _engine = engine;
        _session = s;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _err = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _ensurePermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final cam = await Permission.camera.request();
      final mic = await Permission.microphone.request();
      if (!cam.isGranted || !mic.isGranted) {
        throw Exception('Camera/Microphone permissions are required.');
      }
    }
  }

  Future<void> _cleanup() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.stopPreview();
        await _engine!.release();
      }
    } catch (_) {}
    if (_session != null) {
      try {
        await _repo.leave(_session!.id);
      } catch (_) {}
    }
  }

  void _toggleMic() {
    if (_engine == null) return;
    setState(() => _micOn = !_micOn);
    _engine!.muteLocalAudioStream(!_micOn);
  }

  void _toggleCam() {
    if (_engine == null) return;
    setState(() => _camOn = !_camOn);
    _engine!.muteLocalVideoStream(!_camOn);
  }

  void _switchCamera() => _engine?.switchCamera();

  void _toggleSpeaker() {
    if (_engine == null) return;
    setState(() => _speakerOn = !_speakerOn);
    _engine!.setEnableSpeakerphone(_speakerOn);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_err != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Session')),
        body: Center(
          child: Text(_err!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_session?.title ?? 'Live Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            color: Colors.red,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _joined
                ? _videoGrid()
                : const Center(child: Text('Joining...')),
          ),
          _controlBar(),
        ],
      ),
    );
  }

  Widget _videoGrid() {
    final views = <Widget>[];

    if (_engine != null) {
      // local
      views.add(
        AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _engine!,
            canvas: VideoCanvas(uid: 0),
          ),
        ),
      );

      // remotes
      for (final uid in _remoteUids) {
        views.add(
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine!,
              canvas: VideoCanvas(uid: uid),
              connection: RtcConnection(channelId: _session!.channelName),
            ),
          ),
        );
      }
    }

    if (views.isEmpty) {
      return const Center(
        child: Text('No video yet', style: TextStyle(color: Colors.white)),
      );
    }

    if (views.length == 1) {
      return Container(
        color: Colors.black,
        child: Center(child: SizedBox(height: 220, child: views.first)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: views.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: views.length <= 2 ? 2 : 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, i) => Container(color: Colors.black, child: views[i]),
    );
  }

  Widget _controlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _roundBtn(
            icon: _micOn ? Icons.mic : Icons.mic_off,
            onTap: _toggleMic,
          ),
          _roundBtn(
            icon: _camOn ? Icons.videocam : Icons.videocam_off,
            onTap: _toggleCam,
          ),
          _roundBtn(icon: Icons.flip_camera_android, onTap: _switchCamera),
          _roundBtn(
            icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
            onTap: _toggleSpeaker,
          ),
        ],
      ),
    );
  }

  Widget _roundBtn({required IconData icon, required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      child: CircleAvatar(radius: 26, child: Icon(icon)),
    );
  }
}
