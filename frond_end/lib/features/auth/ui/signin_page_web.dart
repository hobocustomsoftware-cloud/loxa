import 'dart:ui_web' as ui; // web-only
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

// A unique ID for the Google Sign-In button view.
const String _googleSignInButtonViewId = 'google_sign_in_button';

bool _isGoogleSignInViewFactoryRegistered = false;

/// Registers the view factory for the Google Sign-In button (web only).
void _registerGoogleSignInButtonFactory() {
  if (_isGoogleSignInViewFactoryRegistered) {
    return;
  }

  ui.platformViewRegistry.registerViewFactory(_googleSignInButtonViewId, (
    int viewId,
  ) {
    // Configure the Google Identity Services button container
    final gsiButton = html.DivElement()
      ..id = 'g_id_onload'
      ..dataset['client_id'] =
          '676531831869-shs6inbdguae7ijmafs4ne98vp6s5vp1.apps.googleusercontent.com'
      ..dataset['callback'] = 'onGoogleSignIn';

    // Button appearance
    gsiButton.append(
      html.DivElement()
        ..className = 'g_id_signin'
        ..dataset['type'] = 'standard'
        ..dataset['size'] = 'large'
        ..dataset['theme'] = 'outline',
    );

    return gsiButton;
  });

  _isGoogleSignInViewFactoryRegistered = true;
}

/// A custom widget to render the Google Sign-In button on the web.
class _GoogleSignInButtonWeb extends StatefulWidget {
  const _GoogleSignInButtonWeb({required this.authController});

  final AuthController authController;

  @override
  State<_GoogleSignInButtonWeb> createState() => _GoogleSignInButtonWebState();
}

class _GoogleSignInButtonWebState extends State<_GoogleSignInButtonWeb> {
  @override
  void initState() {
    super.initState();

    // Register the factory if it hasn't been already.
    _registerGoogleSignInButtonFactory();

    // Listen for the current user changing.
    GoogleSignIn().onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (account != null) {
        // If sign-in is successful, process it.
        widget.authController.signInWithGoogleFromWeb(account as String);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 220,
      child: const HtmlElementView(viewType: _googleSignInButtonViewId),
    );
  }
}

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

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
                child: _GoogleSignInButtonWeb(
                  authController: authController,
                ),
              ),
      ),
    );
  }
}