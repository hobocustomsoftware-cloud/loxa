// lib/features/live/ui/session_live_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../core/config/agora_config.dart';

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
  late final RtcEngine _engine = createAgoraRtcEngine();

  String _appId = '';
  String _channel = '';
  String _token = '';
  int _uid = 0;

  bool _booting = true;
  String? _err;
  bool _joined = false;
  final _remoteUids = <int>{};

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> _boot() async {
    try {
      // (A) backend → token/app_id/channel/uid
      final t = await LiveApi.instance.token(
        widget.sessionId,
        asHost: widget.asHost,
      );

      // (B) prefer server app_id; otherwise use --dart-define=AGORA_APP_ID
      final appId = resolveAppId(fromServer: t.appId);
      if (appId.isEmpty) {
        throw StateError(
          'Agora App ID is missing (server app_id empty, and no --dart-define).',
        );
      }

      _appId = appId;
      _channel = t.channel;
      _token = t.token; // may be ''
      _uid = t.uid;

      await _initEngine(); // only now, after we have _appId
      await _join();

      if (mounted) setState(() => _booting = false);
    } catch (e, st) {
      debugPrint('boot error: $e\n$st');
      if (mounted)
        setState(() {
          _err = e.toString();
          _booting = false;
        });
    }
  }

  Future<void> _initEngine() async {
    await _engine.initialize(
      RtcEngineContext(
        appId: _appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    await _engine.enableVideo();

    // Broadcaster မဟုတ်ရင် preview မစရ
    if (widget.asHost) {
      await _engine.startPreview();
    }

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        // v6: (RtcConnection connection, int elapsed)
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          if (!mounted) return;
          setState(() => _joined = true);
        },

        // v6: (RtcConnection connection, int remoteUid, int elapsed)
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          if (!mounted) return;
          setState(() => _remoteUids.add(remoteUid));
        },

        // v6: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason)
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              if (!mounted) return;
              setState(() => _remoteUids.remove(remoteUid));
            },

        // v6: (RtcConnection connection, RtcStats stats)
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          if (!mounted) return;
          setState(() => _joined = false);
        },
      ),
    );

    await _engine.setClientRole(
      role: widget.asHost
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );
  }

  Future<void> _join() async {
    await _engine.joinChannel(
      token: _token,
      channelId: _channel,
      uid: _uid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: widget.asHost
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
        publishMicrophoneTrack: widget.asHost,
        publishCameraTrack: widget.asHost,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_err != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 8),
            Text(_err!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _err = null;
                  _booting = true;
                });
                _boot();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // … UI for local/remote video views …
    return const Text('Live joined'); // replace with your video widgets
  }
}
