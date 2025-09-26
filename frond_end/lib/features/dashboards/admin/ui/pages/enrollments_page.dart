// lib/features/dashboards/admin/ui/pages/enrollments_page.dart
import 'package:flutter/material.dart';

class EnrollmentsPage extends StatelessWidget {
  const EnrollmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enrollments', style: h.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search by student/course...',
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
                        label: const Text('New Enrollment'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Student')),
                        DataColumn(label: Text('Course')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Enrolled At')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: const [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
