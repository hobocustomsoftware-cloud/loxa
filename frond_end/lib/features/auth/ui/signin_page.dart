import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../controllers/auth_controller.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthController ကို Provider မှတစ်ဆင့် ရယူခြင်း
    final authController = Provider.of<AuthController>(context);

    // ခလုတ်နှိပ်ပြီး Login ဝင်တဲ့အခါ လုပ်ဆောင်ချက်
    void handleSignIn() async {
      await authController.signInWithGoogle();
      // Login အောင်မြင်ရင် GoRouter ကိုသုံးပြီး အခြား page သို့ redirect လုပ်နိုင်ပါတယ်။
      // ဥပမာ- if (authController.isAuthenticated) context.go('/home');
    }

    // Login ပြီးရင် ပြသမယ့် Profile/Welcome Screen
    if (authController.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Welcome')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  // 🛑 Me Model တွင် 'picture' field မပါဝင်သောကြောင့် Placeholder သာ ပြသပါမည်။
                  // သင့် Backend/Me Model တွင် 'picture' သို့မဟုတ် 'photoUrl' field ထည့်သွင်းပါ။
                  'https://placehold.co/80x80/CCCCCC/333333?text=User',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                // 🛑 Me Model တွင် 'name' field မပါဝင်သောကြောင့် 'email' ကို name အဖြစ် ပြသပါမည်။
                // သင့် Backend/Me Model တွင် 'name' သို့မဟုတ် 'displayName' field ထည့်သွင်းပါ။
                'Hello, ${authController.me!.email}!',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                // email field ကိုတော့ အောင်မြင်စွာ ခေါ်ယူနိုင်သည်ဟု ယူဆပါသည်။
                authController.me!.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                // logout() method ကို အသုံးပြုရန် ပြောင်းလဲထားသည်
                onPressed: authController.logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }

    // Login မဝင်ရသေးရင် ပြသမယ့် Sign-In Screen
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child:
            // ပိုမိုပြည့်စုံသော Loading State အတွက် busy ကို အသုံးပြုရန် ပြောင်းလဲထားသည်
            authController.busy
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Please sign in to continue.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 32),
                    if (kIsWeb)
                      // For web, we use the GoogleSignInButton which handles the GIS flow.
                      // Use a custom widget that wraps HtmlElementView for the web button.
                      _GoogleSignInButtonWeb(authController: authController)
                    else
                      // For mobile, we use a standard button to trigger the sign-in flow.
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.person,
                        ), // Google Logo အစား Icon သုံးထားသည်
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
                  ],
                ),
              ),
      ),
    );
  }
}

// A unique ID for the Google Sign-In button view.
const String _googleSignInButtonViewId = 'google_sign_in_button';

bool _isGoogleSignInViewFactoryRegistered = false;

/// Registers the view factory for the Google Sign-In button.
/// This should be called only once.
void _registerGoogleSignInButtonFactory() {
  // A simple guard to prevent registering the factory more than once.
  if (_isGoogleSignInViewFactoryRegistered) {
    return;
  }

  ui.platformViewRegistry.registerViewFactory(_googleSignInButtonViewId, (
    int viewId,
  ) {
    // 🛑 FIX: The GIS library renders the button into the `g_id_onload` div itself.
    // We need to provide the `data-callback` for the popup flow to work.
    // The `google_sign_in` package will handle the callback.
    final gsiButton = html.DivElement()
      ..id = 'g_id_onload'
      ..dataset['client_id'] =
          '676531831869-shs6inbdguae7ijmafs4ne98vp6s5vp1.apps.googleusercontent.com'
      // Use the callback flow instead of redirect.
      ..dataset['callback'] = 'onGoogleSignIn';

    // We also need to configure the button's appearance.
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
/// This widget uses `HtmlElementView` to embed the button rendered by the
/// Google Identity Services (GIS) library.
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
        widget.authController.signInWithGoogleFromWeb(account);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a SizedBox to control the button's size.
    return SizedBox(
      height: 50,
      width: 220,
      child: HtmlElementView(
        // Use the static viewId.
        viewType: _googleSignInButtonViewId,
      ),
    );
  }
}
