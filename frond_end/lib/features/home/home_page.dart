import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

import '../auth/controllers/auth_controller.dart';

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
          direction: Axis.vertical, // ခလုတ်များကို ဒေါင်လိုက်စီရန်
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Welcome to Loxa! Choose your login type:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ✅ ADDED: Error message display
            Consumer<AuthController>(
              builder: (context, auth, _) {
                if (auth.error == null) return const SizedBox.shrink();
                return Text(
                  auth.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                );
              },
            ),

            // --- Google Sign-In Button ---
            Consumer<AuthController>(
              builder: (context, auth, child) => FilledButton.icon(
                icon: auth.busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.public, size: 20),
                onPressed: auth.busy
                    ? null
                    : () async {
                        if (kIsWeb) {
                          context.go('/google-signin');
                        } else {
                          await context
                              .read<AuthController>()
                              .signInWithGoogle();
                        }
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: Colors.blue.shade700,
                ),
                label: const Text(
                  'Login with Google',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            // ------------------------------------
            const Divider(height: 40, indent: 50, endIndent: 50),

            FilledButton(
              onPressed: () => context.go('/admin/signin'),
              child: const Text('Admin Sign In'),
            ),
            FilledButton(
              onPressed: () => context.go('/student/dashboard'),
              child: const Text('Student Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
