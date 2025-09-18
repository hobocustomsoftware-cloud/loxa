import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class QuickWebVideo extends StatefulWidget {
  final String url;
  const QuickWebVideo({super.key, required this.url});

  @override
  State<QuickWebVideo> createState() => _QuickWebVideoState();
}

class _QuickWebVideoState extends State<QuickWebVideo> {
  late final VideoPlayerController _ctl;
  bool _ready = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      _ctl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _ctl.initialize();
      await _ctl.play();
      setState(() => _ready = true);
    } catch (e) {
      setState(() => _err = '$e');
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_err != null) {
      return Text(_err!, style: const TextStyle(color: Colors.red));
    }
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _ctl.value.aspectRatio == 0
          ? 16 / 9
          : _ctl.value.aspectRatio,
      child: VideoPlayer(_ctl),
    );
  }
}
