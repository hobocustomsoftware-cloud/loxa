import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome 👋', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Check your upcoming live sessions and join right away.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go('/student/live'),
            icon: const Icon(Icons.videocam),
            label: const Text('Go to Live Sessions'),
          ),
        ],
      ),
    );
  }
}
