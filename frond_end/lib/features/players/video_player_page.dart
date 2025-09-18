import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String url;
  const VideoPlayerPage({super.key, required this.url});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _ctl;
  bool _init = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _boot();
    } else {
      // web uses same controller after video_player_web is registered
      _boot();
    }
  }

  Future<void> _boot() async {
    try {
      _ctl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _ctl!.initialize();
      _ctl!.play();
      setState(() => _init = true);
    } catch (e) {
      setState(() => _err = '$e');
    }
  }

  @override
  void dispose() {
    _ctl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_err != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video')),
        body: Center(
          child: Text(_err!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Video')),
      body: Center(
        child: !_init
            ? const CircularProgressIndicator()
            : AspectRatio(
                aspectRatio: _ctl!.value.aspectRatio == 0
                    ? 16 / 9
                    : _ctl!.value.aspectRatio,
                child: VideoPlayer(_ctl!),
              ),
      ),
      floatingActionButton: !_init
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _ctl!.value.isPlaying ? _ctl!.pause() : _ctl!.play();
                });
              },
              child: Icon(
                _ctl!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
    );
  }
}
