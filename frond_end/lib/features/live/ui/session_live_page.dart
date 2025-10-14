import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../auth/controllers/auth_controller.dart';
import '../data/live_api.dart';

class SessionLivePage extends StatefulWidget {
  const SessionLivePage({
    super.key,
    required this.sessionId,
    required this.asHost,
  });

  final int sessionId;
  final bool asHost;

  @override
  State<SessionLivePage> createState() => _SessionLivePageState();
}

class _SessionLivePageState extends State<SessionLivePage> {
  late final RtcEngine _engine;

  String _appId = '';
  String _channel = '';
  String _token = '';
  int _uid = 0;

  // RE-ADDED: Keep track of the user's role
  bool _isHost = false;
  bool _joined = false;

  bool _micOn = true;
  bool _camOn = true;
  bool _speakerOn = true;

  final Set<int> _remoteUids = LinkedHashSet();
  bool _engineInited = false;

  @override
  void initState() {
    super.initState();
    // Set the initial host status from the widget
    _isHost = widget.asHost;
    _engine = createAgoraRtcEngine();
    _boot();
  }

  @override
  void dispose() {
    () async {
      await _engine.leaveChannel();
      await _engine.release();
    }();
    super.dispose();
  }

  Future<void> _boot() async {
    final t = await LiveApi.instance.token(
      widget.sessionId,
      asHost: widget.asHost,
    );

    _appId = t.appId;
    _channel = t.channel;
    _token = t.token;
    _uid = t.uid;

    await _initEngine();

    await _engine.enableLocalVideo(_camOn);
    if (_camOn) {
      await _engine.startPreview();
    }
    await _engine.muteLocalAudioStream(!_micOn);
    await _engine.muteLocalVideoStream(!_camOn);

    await _engine.joinChannel(
      token: _token,
      channelId: _channel,
      uid: _uid,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _initEngine() async {
    if (_engineInited) return;

    await _engine.initialize(RtcEngineContext(appId: _appId));
    await _engine.setParameters(r'{"rtc.log_filter": 65535}');

    // Use Communication profile for Google Meet style functionality
    await _engine.setChannelProfile(
      ChannelProfileType.channelProfileCommunication,
    );

    await _engine.enableVideo();
    await _engine.enableAudio();

    await _engine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) => debugPrint('❌ error: $err, msg: $msg'),
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint(
            '✔ joined ch=${connection.channelId} uid=${connection.localUid}',
          );
          if (mounted) setState(() => _joined = true);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint('👤 user joined $remoteUid');
          if (mounted) setState(() => _remoteUids.add(remoteUid));
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint('👤 user offline $remoteUid reason=${reason.name}');
          if (mounted) setState(() => _remoteUids.remove(remoteUid));
        },
        onLeaveChannel: (connection, stats) {
          if (!mounted) return;
          setState(() {
            _joined = false;
            _remoteUids.clear();
          });
        },
      ),
    );
    _engineInited = true;
  }

  // Simplified toggle functions for Communication mode
  Future<void> _toggleCam() async {
    setState(() => _camOn = !_camOn);
    await _engine.muteLocalVideoStream(!_camOn);
    // Also toggle the camera hardware to save battery
    await _engine.enableLocalVideo(_camOn);
    if (_camOn) {
      await _engine.startPreview();
    } else {
      await _engine.stopPreview();
    }
  }

  Future<void> _toggleMic() async {
    setState(() => _micOn = !_micOn);
    await _engine.muteLocalAudioStream(!_micOn);
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _speakerOn = !_speakerOn);
    await _engine.adjustPlaybackSignalVolume(_speakerOn ? 100 : 0);
  }

  Future<void> _leave() async {
    await _engine.leaveChannel();
    // Use GoRouter's pop for better integration with the navigation stack.
    if (mounted) context.pop();
  }

  Widget _buildVideoPanel(int uid) {
    bool isLocal = uid == 0;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black38,
      ),
      child: isLocal
          ? AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            )
          : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: uid),
                connection: RtcConnection(channelId: _channel),
              ),
            ),
    );
  }

  Widget _buildVideoArea() {
    if (!_joined) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Widget> videoPanels = [
      _buildVideoPanel(0),
    ]; // Start with the local user
    for (final uid in _remoteUids) {
      videoPanels.add(_buildVideoPanel(uid));
    }

    // Adaptive layout for better UX
    if (videoPanels.length == 1) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: videoPanels.first,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: videoPanels.length,
      itemBuilder: (context, index) => videoPanels[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    // RE-ADDED: Display role in the AppBar title
    final roleText = _isHost ? 'Host' : 'Audience';

    final actions = <Widget>[
      IconButton(
        tooltip: _speakerOn ? 'Mute speakers' : 'Unmute speakers',
        onPressed: _toggleSpeaker,
        icon: Icon(_speakerOn ? Icons.volume_up : Icons.volume_off),
      ),
      IconButton(
        tooltip: _micOn ? 'Mute mic' : 'Unmute mic',
        onPressed: _toggleMic,
        icon: Icon(_micOn ? Icons.mic : Icons.mic_off),
      ),
      IconButton(
        tooltip: _camOn ? 'Turn camera off' : 'Turn camera on',
        onPressed: _toggleCam,
        icon: Icon(_camOn ? Icons.videocam : Icons.videocam_off),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _leave,
          icon: const Icon(Icons.call_end),
          label: const Text('Leave'),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Live Session ($roleText)'), actions: actions),
      body: _buildVideoArea(),
      backgroundColor: Colors.black87,
    );
  }
}
