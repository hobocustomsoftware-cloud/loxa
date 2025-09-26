// lib/features/dashboards/admin/ui/pages/admin_live_sessions_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../live/data/live_api.dart';

class AdminLiveSessionsPage extends StatefulWidget {
  const AdminLiveSessionsPage({super.key});
  @override
  State<AdminLiveSessionsPage> createState() => _AdminLiveSessionsPageState();
}

class _AdminLiveSessionsPageState extends State<AdminLiveSessionsPage> {
  late Future<List<Map<String, dynamic>>> _future;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _future = LiveApi.instance.listSessions(mine: true);
  }

  Future<void> _reload() async {
    setState(() => _future = LiveApi.instance.listSessions(mine: true));
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      await LiveApi.instance.createSession(
        title: 'Session ${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold ထဲ → Column → Expanded(ListView) : single scrollable
    return Scaffold(
      backgroundColor: Colors.transparent, // shell bg ကိုလိုချင်လို့
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Toolbar
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Live Sessions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _creating ? null : _create,
                  icon: _creating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(_creating ? 'Creating…' : 'Create'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Body
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return _ErrorBox(
                      message: 'Failed to load sessions',
                      detail: snap.error.toString(),
                      onRetry: _reload,
                    );
                  }
                  final items = snap.data ?? const [];
                  if (items.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No sessions yet')),
                          SizedBox(height: 400),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final s = items[i];
                        final id = (s['id'] as num?)?.toInt() ?? 0;
                        final title = (s['title'] ?? 'Untitled').toString();
                        final start = (s['start_time'] ?? '').toString();
                        return ListTile(
                          title: Text(title),
                          subtitle: Text(start),
                          trailing: FilledButton(
                            onPressed: id == 0
                                ? null
                                : () =>
                                      context.go('/live/session/$id?role=host'),
                            child: const Text('Open'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final String? detail;
  final Future<void> Function() onRetry;
  const _ErrorBox({required this.message, this.detail, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 32, color: cs.error),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(detail!, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
