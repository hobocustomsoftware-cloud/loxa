import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/admin_scaffold.dart';
import '../data/course_admin_models.dart';
import '../state/course_admin_controller.dart';
import 'course_edit_dialog.dart';

class AdminCoursesPage extends StatelessWidget {
  const AdminCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseAdminController()..reload(),
      child: AdminScaffold(
        child: Consumer<CourseAdminController>(
          builder: (_, vm, __) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search courses',
                          ),
                          onChanged: (v) {
                            vm.search = v;
                            vm.reload();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('New'),
                        onPressed: () async {
                          final input = await showDialog<AdminCourse>(
                            context: context,
                            builder: (_) => const CourseEditDialog(),
                          );
                          if (input != null) {
                            await vm.createOrUpdate(null, input);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (vm.loading) const LinearProgressIndicator(),
                  if (vm.error != null)
                    Text(vm.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
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
                          rows: vm.items.map((c) {
                            return DataRow(
                              cells: [
                                DataCell(Text('${c.id}')),
                                DataCell(Text(c.title)),
                                DataCell(Text(c.programLabel ?? '—')),
                                DataCell(Text(c.levelLabel ?? '—')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () async {
                                          final edited =
                                              await showDialog<AdminCourse>(
                                                context: context,
                                                builder: (_) =>
                                                    CourseEditDialog(
                                                      initial: c,
                                                    ),
                                              );
                                          if (edited != null) {
                                            await vm.createOrUpdate(c, edited);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final ok = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text(
                                                'Delete Course',
                                              ),
                                              content: Text(
                                                'Delete "${c.title}" ?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (ok == true) {
                                            await vm.remove(c.id);
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
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
