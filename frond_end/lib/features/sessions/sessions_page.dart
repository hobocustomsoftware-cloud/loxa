import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api/dio_client.dart';
import '../../core/utils/constants.dart';
import '../../widgets/common_widgets.dart';
import 'session_model.dart';
import 'package:go_router/go_router.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});
  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  List<SessionModel> items = [];
  bool loading = true;
  String? err;
  String filter = 'all';
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => loading = true);
    try {
      final r = await DioClient.instance.dio.get(
        Constants.sessions,
        options: Options(headers: {'X-Org-ID': '1'}),
        queryParameters: filter == 'all' ? null : {'status': filter},
      );
      final data = r.data;
      final list = (data['results'] ?? data) as List;
      items = list.map((e) => SessionModel.fromJson(e)).toList();
      err = null;
    } catch (e) {
      err = '$e';
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Loading();
    if (err != null) return ErrorText(err!);
    if (items.isEmpty) {
      return const EmptyState(
        title: 'No sessions',
        subtitle: 'Create sessions from admin.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              const Text('Filter:'),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: filter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'live', child: Text('Live')),
                  DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                  DropdownMenuItem(value: 'ended', child: Text('Ended')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => filter = v);
                    _fetch();
                  }
                },
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _fetch,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemBuilder: (_, i) => _tile(items[i], context),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }

  Widget _tile(SessionModel s, BuildContext ctx) => ListTile(
    leading: Icon(_iconFor(s.status), color: _colorFor(ctx, s.status)),
    title: Text(s.title),
    subtitle: Text('${s.status.toUpperCase()} • ${s.start ?? '-'}'),
    trailing: Wrap(
      spacing: 8,
      children: [
        if (s.status == 'live')
          FilledButton(
            onPressed: () => ctx.go('/agora'),
            child: const Text('Join'),
          ),
        OutlinedButton(
          onPressed: () => ctx.go('/sessions/${s.id}'),
          child: const Text('Details'),
        ),
      ],
    ),
  );

  IconData _iconFor(String st) => st == 'live'
      ? Icons.wifi_tethering
      : st == 'ended'
      ? Icons.stop_circle_outlined
      : Icons.schedule;
  Color _colorFor(BuildContext c, String st) =>
      st == 'live' ? Colors.red : Theme.of(c).colorScheme.primary;
}
