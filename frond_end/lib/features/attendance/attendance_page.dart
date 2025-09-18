import 'package:flutter/material.dart';
import '../../core/api/dio_client.dart';
import '../../core/utils/constants.dart';
import '../../widgets/common_widgets.dart';
import 'attendance_model.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Attendance> rows = [];
  bool loading = true;
  String? err;
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final r = await DioClient.instance.dio.get(Constants.attendance);
      final list = (r.data['results'] ?? r.data) as List;
      rows = list.map((e) => Attendance.fromJson(e)).toList();
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
    if (rows.isEmpty)
      return const EmptyState(
        title: 'No attendance',
        subtitle: 'Join sessions to create records.',
      );
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: Text(rows[i].user),
        subtitle: Text(rows[i].status),
      ),
    );
  }
}
