import 'package:flutter/material.dart';
import '../../core/api/dio_client.dart';
import '../../core/utils/constants.dart';
import '../../widgets/common_widgets.dart';

class SessionDetailPage extends StatefulWidget {
  final String id;
  const SessionDetailPage({super.key, required this.id});
  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  Map? data;
  bool loading = true;
  String? err;
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final r = await DioClient.instance.dio.get(
        '${Constants.sessions}${widget.id}/',
      );
      data = r.data;
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
    if (data == null)
      return const EmptyState(
        title: 'Not found',
        subtitle: 'Session not found',
      );

    return Scaffold(
      appBar: AppBar(title: Text(data!['title'] ?? 'Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${data!['status'] ?? '-'}'),
            const SizedBox(height: 8),
            Text('Start: ${data!['start_time'] ?? '-'}'),
            Text('End:   ${data!['end_time'] ?? '-'}'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.people_outline),
              label: const Text('View attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
