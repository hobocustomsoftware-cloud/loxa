// lib/features/live/ui/live_session_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/live_api.dart';

class LiveSessionPage extends StatefulWidget {
  const LiveSessionPage({super.key});
  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = LiveApi.instance.listSessions(mine: true);
  }

  Future<void> _reload() async {
    setState(() => _future = LiveApi.instance.listSessions(mine: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Sessions (Agora)')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            // 401/403 အတွက် UX သေချာ
            return Center(child: Text('Load failed: ${snap.error}'));
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No sessions yet')),
                  SizedBox(height: 600),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = items[i];
                final id = s['id'];
                final title = (s['title'] ?? 'Untitled').toString();
                final start = (s['start_time'] ?? '').toString();
                return ListTile(
                  title: Text(title),
                  subtitle: Text(start),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () =>
                            context.go('/live/session/$id?role=audience'),
                        child: const Text('Join'),
                      ),
                      const SizedBox(width: 6),
                      FilledButton(
                        onPressed: () =>
                            context.go('/live/session/$id?role=host'),
                        child: const Text('Host'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
