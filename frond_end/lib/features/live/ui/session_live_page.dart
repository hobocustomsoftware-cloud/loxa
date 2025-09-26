import 'dart:math';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../live/data/live_api.dart';

class SessionLivePage extends StatefulWidget {
  final int sessionId;
  final bool
  asHost; // true = Host (instructor/admin), false = Audience (student)
  const SessionLivePage({
    super.key,
    required this.sessionId,
    required this.asHost,
  });

  @override
  State<SessionLivePage> createState() => _SessionLivePageState();
}

class _SessionLivePageState extends State<SessionLivePage> {
  late final RtcEngine _engine = createAgoraRtcEngine();
  bool _ready = false, _joined = false, _joining = false;
  final List<int> _remote = [];
  final int _uid = Random().nextInt(1 << 31);
  ClientRoleType get _role => widget.asHost
      ? ClientRoleType.clientRoleBroadcaster
      : ClientRoleType.clientRoleAudience;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _leave();
    _engine.release();
    super.dispose();
  }

  Future<void> _init() async {
    await _engine.initialize(
      RtcEngineContext(
        appId: const String.fromEnvironment('AGORA_APP_ID'),
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (_, __) => setState(() => _joined = true),
        onLeaveChannel: (_, __) => setState(() {
          _joined = false;
          _remote.clear();
        }),
        onUserJoined: (_, uid, __) => setState(() => _remote.add(uid)),
        onUserOffline: (_, uid, __) => setState(() => _remote.remove(uid)),
      ),
    );
    await _engine.enableVideo();
    setState(() => _ready = true);
    _join();
  }

  Future<void> _join() async {
    if (_joining || !_ready) return;
    setState(() => _joining = true);
    try {
      await LiveApi.instance.join(widget.sessionId);
      final tok = await LiveApi.instance.token(
        widget.sessionId,
        asHost: widget.asHost,
      );

      await _engine.setClientRole(role: _role);
      if (widget.asHost) await _engine.startPreview();

      await _engine.joinChannel(
        token: tok.token,
        channelId: tok.channel,
        uid: tok.uid, // server-provided
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: _role,
          publishCameraTrack: widget.asHost,
          publishMicrophoneTrack: widget.asHost,
        ),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _leave() async {
    try {
      await _engine.leaveChannel();
      await _engine.stopPreview();
    } catch (_) {}
    try {
      await LiveApi.instance.leave(widget.sessionId);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Live Session #${widget.sessionId}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _joined ? null : _join,
                icon: _joining
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_joined ? 'Joined' : 'Join'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _joined ? _leave : null,
                icon: const Icon(Icons.stop),
                label: const Text('Leave'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    child: _joined && widget.asHost
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : Center(
                            child: Text(
                              _joined ? 'Audience Mode' : 'Not joined',
                              style: TextStyle(color: cs.outline),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    elevation: 0,
                    child: _remote.isEmpty
                        ? Center(
                            child: Text(
                              'Waiting for remote…',
                              style: TextStyle(color: cs.outline),
                            ),
                          )
                        : AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: _engine,
                              connection: RtcConnection(
                                channelId: '',
                              ), // the engine tracks channel internally; can supply if needed
                              canvas: VideoCanvas(uid: _remote.first),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
