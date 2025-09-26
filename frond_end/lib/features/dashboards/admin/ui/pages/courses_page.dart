// lib/features/dashboards/admin/ui/pages/courses_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});
  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _searchCtl = TextEditingController();
  final List<_CourseRowVM> _all = const [
    _CourseRowVM(
      id: 'c101',
      title: 'Advanced Python',
      instructor: 'John',
      students: 5200,
      status: 'Published',
    ),
    _CourseRowVM(
      id: 'c102',
      title: 'ML Basics',
      instructor: 'Mary',
      students: 4800,
      status: 'Draft',
    ),
    _CourseRowVM(
      id: 'c103',
      title: 'Web Dev Bootcamp',
      instructor: 'Alex',
      students: 3100,
      status: 'Published',
    ),
    _CourseRowVM(
      id: 'c104',
      title: 'Data Science w/ R',
      instructor: 'Sara',
      students: 2500,
      status: 'Published',
    ),
  ];

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchCtl.text.trim().toLowerCase();
    final rows = _all.where((c) => c.title.toLowerCase().contains(q)).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search courses…',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('New Course'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Instructor')),
                      DataColumn(label: Text('Students')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: rows
                        .map(
                          (c) => DataRow(
                            onSelectChanged: (sel) {
                              if (sel == true) {
                                // ✅ ID-only navigation (no extra objects)
                                context.goNamed(
                                  'admin_course_detail',
                                  pathParameters: {'id': c.id},
                                );
                              }
                            },
                            cells: [
                              DataCell(Text(c.id)),
                              DataCell(Text(c.title)),
                              DataCell(Text(c.instructor ?? '-')),
                              DataCell(Text('${c.students}')),
                              DataCell(
                                Text(
                                  c.status,
                                  style: TextStyle(
                                    color: c.status == 'Published'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
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
          ),
        ],
      ),
    );
  }
}

class _CourseRowVM {
  final String id, title, status;
  final String? instructor;
  final int students;
  const _CourseRowVM({
    required this.id,
    required this.title,
    this.instructor,
    required this.students,
    required this.status,
  });
}
