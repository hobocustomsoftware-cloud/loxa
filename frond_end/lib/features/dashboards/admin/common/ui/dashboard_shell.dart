import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.only(top: 24),
          children: [
            const ListTile(
              title: Text(
                'Loxa Admin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Admin'),
              onTap: () => context.go('/admin'),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Org'),
              onTap: () => context.go('/org'),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Teacher'),
              onTap: () => context.go('/teacher'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Student'),
              onTap: () => context.go('/student'),
            ),
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: const Text('Parent'),
              onTap: () => context.go('/parent'),
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text('Dashboard')),
      body: child,
    );
  }
}
