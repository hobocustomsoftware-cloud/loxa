import 'package:flutter/material.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;
  const AdminScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Admin')),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Courses'),
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed('/admin/courses'),
            ),
            // TODO: modules, lessons, users, sessions...
          ],
        ),
      ),
      body: child,
    );
  }
}
