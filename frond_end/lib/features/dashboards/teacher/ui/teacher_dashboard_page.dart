// lib/features/dashboards/teacher/ui/teacher_dashboard_page.dart
import 'package:flutter/material.dart';

class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Teacher Dashboard',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            leading: Icon(Icons.class_),
            title: Text('Grade 1 - Myanmar'),
            subtitle: Text('Next session: Today 2:00 PM'),
          ),
        ),
      ],
    );
  }
}
