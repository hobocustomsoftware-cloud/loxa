import 'package:flutter/material.dart';
import 'agora_service.dart';

class AgoraPage extends StatefulWidget {
  const AgoraPage({super.key});
  @override
  State<AgoraPage> createState() => _AgoraPageState();
}

class _AgoraPageState extends State<AgoraPage> {
  final _channel = TextEditingController(text: 'demo');
  String? _token;
  bool _loading = false;
  String? _err;

  Future<void> _getToken() async {
    setState(() => _loading = true);
    setState(() => _err = null);
    try {
      final t = await AgoraService().fetchToken(_channel.text.trim());
      setState(() => _token = t);
    } catch (e) {
      setState(() => _err = '$e');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agora Join')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _channel,
              decoration: const InputDecoration(labelText: 'Channel'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _getToken,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Get Token'),
            ),
            const SizedBox(height: 12),
            if (_err != null)
              Text(_err!, style: const TextStyle(color: Colors.red)),
            if (_token != null) SelectableText('Token: $_token'),
          ],
        ),
      ),
    );
  }
}
