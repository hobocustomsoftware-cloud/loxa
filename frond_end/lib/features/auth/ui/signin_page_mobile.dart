import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    Future<void> handleSignIn() async {
      await authController.signInWithGoogle();
    }

    if (authController.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Welcome')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://placehold.co/80x80/CCCCCC/333333?text=User',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hello, ${authController.me!.email}!',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                authController.me!.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: authController.logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: authController.busy
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Sign in with Google'),
                  onPressed: handleSignIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}