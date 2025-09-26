// lib/features/dashboards/super/ui/super_admin_dashboard_page.dart
import 'package:flutter/material.dart';

class SuperAdminDashboardPage extends StatelessWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Super Admin – Organizations',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.domain),
            title: const Text('ITEC'),
            subtitle: const Text('Type: KG'),
            trailing: FilledButton(
              onPressed: () {},
              child: const Text('Manage'),
            ),
          ),
        ),
      ],
    );
  }
}
