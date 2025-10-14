// lib/features/auth/ui/admin_signin_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

class AdminSignInPage extends StatefulWidget {
  const AdminSignInPage({super.key});

  @override
  State<AdminSignInPage> createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends State<AdminSignInPage> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _submitting = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    // Already logged-in ⇒ auto-redirect to the right dashboard.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (!auth.isLoggedIn) return;
      final isAdminish = auth.isAdmin || auth.isModerator || auth.isEditor;
      if (!mounted) return;
      context.go(isAdminish ? '/admin/dashboard' : '/student/dashboard');
    });
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _err = null;
    });

    try {
      final auth = context.read<AuthController>();
      final ok = await auth.login(
        email: _emailCtl.text.trim(),
        password: _passCtl.text,
      );
      if (!mounted) return;

      if (!ok) {
        setState(() => _err = auth.error ?? 'Login failed.');
        return;
      }

      final isAdminish = auth.isAdmin || auth.isModerator || auth.isEditor;

      // ✅ Navigate and return — don’t setState error after this.
      context.go(isAdminish ? '/admin/dashboard' : '/student/dashboard');
      return;
    } catch (e) {
      if (mounted) {
        setState(() => _err = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final email = v.trim();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return ok ? null : 'Enter a valid email';
  }

  @override
  Widget build(BuildContext context) {
    final busy = _submitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Sign In')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailCtl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      enabled: !busy,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passCtl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password is required'
                          : null,
                      enabled: !busy,
                    ),
                    const SizedBox(height: 16),
                    if (_err != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _err!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submit, // 👈 single source of truth
                        child: busy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
