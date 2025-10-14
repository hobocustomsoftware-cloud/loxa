import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class StudentSignInPage extends StatefulWidget {
  const StudentSignInPage({super.key});
  @override
  State<StudentSignInPage> createState() => _StudentSignInPageState();
}

class _StudentSignInPageState extends State<StudentSignInPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _submit() async {
    final ok = await context.read<AuthController>().login(
      email: _email.text.trim(),
      password: _pass.text,
    );
    if (!ok || !mounted) return;
    context.go('/student/dashboard'); // ✅
  }

  @override
  Widget build(BuildContext context) {
    // minimal form...
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Student Sign In',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _submit, child: const Text('Sign In')),
              TextButton(
                onPressed: () => context.go('/admin/signin'),
                child: const Text('I am an admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
