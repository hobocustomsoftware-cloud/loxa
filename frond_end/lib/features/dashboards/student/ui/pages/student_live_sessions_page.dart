import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../live/data/live_api.dart';

class StudentLiveSessionsPage extends StatefulWidget {
  const StudentLiveSessionsPage({super.key});
  @override
  State<StudentLiveSessionsPage> createState() =>
      _StudentLiveSessionsPageState();
}

class _StudentLiveSessionsPageState extends State<StudentLiveSessionsPage> {
  late Future<List<Map<String, dynamic>>> _future = LiveApi.instance
      .listSessions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (c, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty)
            return const Center(child: Text('No live sessions yet.'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final s = items[i];
              final id = (s['id'] as num).toInt();
              return Card(
                elevation: 0,
                child: ListTile(
                  title: Text(s['title']?.toString() ?? 'Live #$id'),
                  subtitle: Text('Channel: ${s['channel_name'] ?? '-'}'),
                  trailing: FilledButton(
                    onPressed: () =>
                        context.go('/live/session/$id?role=audience'),
                    child: const Text('Join'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
