// lib/features/dashboards/admin/ui/pages/reports_page.dart
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('Reports', style: h.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Enrollment by Month'),
              subtitle: const Text('See monthly enrollment trends'),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('View'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Revenue Breakdown'),
              subtitle: const Text('Payments by course / plan'),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('View'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
