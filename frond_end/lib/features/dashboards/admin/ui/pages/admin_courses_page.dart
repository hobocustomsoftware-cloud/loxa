// lib/features/admin/ui/pages/admin_courses_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/controllers/auth_controller.dart';
import '../../controllers/admin_courses_controller.dart';
import '../../data/admin_courses_repository.dart';
import '../widgets/course_form_dialog.dart';
import '../widgets/confirm_delete_dialog.dart';

class AdminCoursesPage extends StatelessWidget {
  const AdminCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminCoursesController(AdminCoursesRepository())..load(),
      child: const _AdminCoursesView(),
    );
  }
}

class _AdminCoursesView extends StatefulWidget {
  const _AdminCoursesView();

  @override
  State<_AdminCoursesView> createState() => _AdminCoursesViewState();
}

class _AdminCoursesViewState extends State<_AdminCoursesView> {
  final _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminCoursesController>();
    final auth = context.watch<AuthController>(); // permission guard (optional)

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => vm.load(),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: auth.isAdmin
            ? () async {
                final draft = await showDialog<AdminCourse>(
                  context: context,
                  builder: (_) => const CourseFormDialog(),
                );
                if (draft != null) {
                  final ok = await vm.create(draft);
                  if (!ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(vm.error ?? 'Create failed')),
                    );
                  }
                }
              }
            : null,
        label: const Text('New Course'),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search title / code ...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      vm.search = _searchCtl.text.trim();
                      vm.load(toPage: 1);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    vm.search = _searchCtl.text.trim();
                    vm.load(toPage: 1);
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (vm.loading) const LinearProgressIndicator(),
            if (vm.error != null)
              Text(vm.error!, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Program')),
                      DataColumn(label: Text('Level')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: vm.items
                        .map(
                          (c) => DataRow(
                            cells: [
                              DataCell(Text('${c.id}')),
                              DataCell(Text(c.title)),
                              DataCell(Text(c.programLabel ?? '—')),
                              DataCell(Text(c.levelLabel ?? '—')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Edit',
                                      onPressed: () async {
                                        final draft =
                                            await showDialog<AdminCourse>(
                                              context: context,
                                              builder: (_) =>
                                                  CourseFormDialog(initial: c),
                                            );
                                        if (draft != null) {
                                          final ok = await vm.update(draft);
                                          if (!ok && mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  vm.error ?? 'Update failed',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      onPressed: () async {
                                        final ok = await confirmDelete(
                                          context,
                                          'course "${c.title}"',
                                        );
                                        if (ok) {
                                          final done = await vm.delete(c.id);
                                          if (!done && mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  vm.error ?? 'Delete failed',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Total: ${vm.total}'),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: vm.page > 1
                      ? () => vm.load(toPage: vm.page - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Page ${vm.page}'),
                IconButton(
                  onPressed: vm.items.length == vm.pageSize
                      ? () => vm.load(toPage: vm.page + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
