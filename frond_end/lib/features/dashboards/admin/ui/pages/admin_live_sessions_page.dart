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
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= LiveApi.instance.listSessions(mine: true);
  }

  void _reload() {
    setState(() => _future = LiveApi.instance.listSessions(mine: true));
  }

  Future<void> _create() async {
    try {
      await LiveApi.instance.createSession(
        title: 'Session ${DateTime.now().millisecondsSinceEpoch}',
      );
      _reload();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final future = _future ?? Future.value(const <Map<String, dynamic>>[]);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snap) {
        final slivers = <Widget>[
          // toolbar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search…',
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _create,
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                  ),
                ],
              ),
            ),
          ),
        ];

        if (snap.hasError) {
          slivers.add(
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Failed to load')),
            ),
          );
        } else if (snap.connectionState != ConnectionState.done) {
          slivers.add(
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            slivers.add(
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No sessions yet')),
              ),
            );
          } else {
            slivers.add(
              SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = items[i];
                  final id = s['id'];
                  return ListTile(
                    title: Text('${s['title']}'),
                    subtitle: Text('${s['start_time']}'),
                    trailing: FilledButton(
                      onPressed: () =>
                          context.go('/live/session/$id?role=host'),
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            );
          }
        }

        return RefreshIndicator.adaptive(
          onRefresh: () async => _reload(),
          child: CustomScrollView(
            slivers: [
              const SliverPadding(padding: EdgeInsets.all(16)),
              ...slivers,
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        );
      },
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
