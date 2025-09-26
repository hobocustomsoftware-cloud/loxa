// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loxa')),
      body: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => context.go('/admin/signin'),
              child: const Text('Admin Sign In'),
            ),
            FilledButton(
              onPressed: () => context.go('/student'),
              child: const Text('Student Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
