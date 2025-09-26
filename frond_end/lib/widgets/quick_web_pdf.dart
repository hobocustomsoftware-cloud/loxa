import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class QuickWebPdf extends StatelessWidget {
  final String url;
  const QuickWebPdf({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Center(
        child: Text('PDF preview available on web only demo'),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: HtmlElementView(viewType: createWebPdfView(url)),
      ),
    );
  }
}

String createWebPdfView(String url) {
  final id = 'web-pdf-${url.hashCode}';
  return id;
}
