import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api/dio_client.dart';
import '../../core/utils/constants.dart';
import '../../widgets/common_widgets.dart';
import 'seat_model.dart';

class SeatsPage extends StatefulWidget {
  const SeatsPage({super.key});
  @override
  State<SeatsPage> createState() => _SeatsPageState();
}

class _SeatsPageState extends State<SeatsPage> {
  List<Seat> rows = [];
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
        Constants.seats,
        options: Options(headers: {'X-Org-ID': '1'}),
      );
      final list = (r.data['results'] ?? r.data) as List;
      rows = list.map((e) => Seat.fromJson(e)).toList();
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
    if (rows.isEmpty) {
      return EmptyState(title: 'No seats', subtitle: 'No reservations yet.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemBuilder: (_, i) => ListTile(
        leading: Icon(
          rows[i].status == 'reserved'
              ? Icons.event_seat
              : Icons.event_seat_outlined,
        ),
        title: Text('Session: ${rows[i].session}'),
        subtitle: Text(
          'Status: ${rows[i].status}${rows[i].user != null ? ' • User: ${rows[i].user}' : ''}',
        ),
      ),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: rows.length,
    );
  }
}
