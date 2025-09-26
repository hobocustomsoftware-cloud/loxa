// lib/features/dashboards/parent/ui/parent_dashboard_page.dart
import 'package:flutter/material.dart';

class ParentDashboardPage extends StatelessWidget {
  const ParentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Parent Dashboard', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            leading: Icon(Icons.child_care),
            title: Text('Child: Aye Aye'),
            subtitle: Text('Progress: 45%'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }
}
