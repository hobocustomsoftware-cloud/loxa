import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api/dio_client.dart';
import '../../core/utils/constants.dart';
import '../../widgets/common_widgets.dart';
import 'module_model.dart';

class ModulesPage extends StatefulWidget {
  const ModulesPage({super.key});
  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
  List<Module> items = [];
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
        Constants.modules,
        options: Options(headers: {'X-Org-ID': '1'}),
      );
      final list = (r.data['results'] ?? r.data) as List;
      items = list.map((e) => Module.fromJson(e)).toList();
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
    if (items.isEmpty)
      return const EmptyState(
        title: 'No modules',
        subtitle: 'Create modules inside courses.',
      );
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.view_module_outlined),
        title: Text(items[i].title),
        subtitle: Text(
          items[i].description ?? '-',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
    );
  }
}
