// lib/features/dashboards/admin/widgets/orgs_panel.dart
import 'package:flutter/material.dart';

import '../../../orgs/data/org_repository.dart';

class OrgsPanel extends StatefulWidget {
  const OrgsPanel({super.key});
  @override
  State<OrgsPanel> createState() => _OrgsPanelState();
}

class _OrgsPanelState extends State<OrgsPanel> {
  final _repo = OrgRepository();
  late Future<List<Org>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.list();
  }

  Future<void> _reload() async {
    setState(() => _future = _repo.list());
  }

  Future<void> _createDialog() async {
    final nameCtl = TextEditingController();
    final typeCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Org'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: typeCtl,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _repo.create(name: nameCtl.text.trim(), type: typeCtl.text.trim());
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder<List<Org>>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData)
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            );
          final rows = snap.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: const Text('Organizations'),
                trailing: FilledButton.icon(
                  onPressed: _createDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New Org'),
                ),
              ),
              const Divider(height: 1),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: rows.map((o) {
                    return DataRow(
                      cells: [
                        DataCell(Text('${o.id}')),
                        DataCell(Text(o.name)),
                        DataCell(Text(o.type ?? '—')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Delete Org?'),
                                      content: Text('Delete "${o.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _repo.delete(o.id);
                                    await _reload();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
