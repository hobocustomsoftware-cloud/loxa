// lib/features/lesson/widgets/asset_viewer.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/quick_web_video.dart'; // web fallback you wrote

class AssetViewer extends StatelessWidget {
  final String type; // 'VIDEO'|'RECORDING'|'PDF'
  final String? url; // or file path
  const AssetViewer({super.key, required this.type, this.url});

  @override
  Widget build(BuildContext context) {
    if (type == 'PDF') {
      // simple open in new tab for web; or PDF viewer on mobile
      return ElevatedButton.icon(
        onPressed: url == null
            ? null
            : () => launchUrl(
                Uri.parse(url!),
                mode: LaunchMode.externalApplication,
              ),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Open PDF'),
      );
    }
    // VIDEO/RECORDING
    if (url == null) return const Text('No media');
    return QuickWebVideo(url: url!); // your web-safe player
  }
}
