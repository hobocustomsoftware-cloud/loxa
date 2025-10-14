import 'package:google_sign_in/google_sign_in.dart';

class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? token; // Backend token (if authenticated)

  User({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.token,
  });

  // Factory method to create User from GoogleSignInAccount
  factory User.fromGoogleAccount({
    required String token,
    required GoogleSignInAccount account,
  }) {
    return User(
      uid: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
      token: token,
    );
  }

  // A method for easy copying (useful when updating the token)
  User copyWith({String? token}) {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      token: token ?? this.token,
    );
  }
}
