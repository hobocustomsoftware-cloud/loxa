import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api/dio_client.dart';
import '../../core/utils/constants.dart';
import '../../widgets/common_widgets.dart';
import 'asset_model.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});
  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  List<LessonAssetModel> items = [];
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
        Constants.assets,
        options: Options(headers: {'X-Org-ID': '1'}),
      );
      final list = (r.data['results'] ?? r.data) as List;
      items = list.map((e) => LessonAssetModel.fromJson(e)).toList();
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
        title: 'No assets',
        subtitle: 'Upload lesson assets.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.insert_drive_file_outlined),
        title: Text(items[i].title),
        subtitle: Text('${items[i].kind ?? 'file'} • ${items[i].url ?? '-'}'),
      ),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
    );
  }
}
