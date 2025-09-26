// lib/features/dashboards/org/ui/org_dashboard_page.dart
import 'package:flutter/material.dart';

class OrgDashboardPage extends StatelessWidget {
  const OrgDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Organization Dashboard',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            title: Text('Teachers: 8'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Students: 120'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Courses: 4'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }
}
