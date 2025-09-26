// Minimal models for auth payload
class JwtTokens {
  final String access;
  final String refresh;
  const JwtTokens({required this.access, required this.refresh});

  factory JwtTokens.fromJson(Map<String, dynamic> j) =>
      JwtTokens(access: j['access'] as String, refresh: j['refresh'] as String);

  Map<String, dynamic> toJson() => {'access': access, 'refresh': refresh};
}

class UserProfile {
  final int id;
  final String username;
  final String? email;
  const UserProfile({required this.id, required this.username, this.email});

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id: j['id'] as int,
    username: j['username'] as String,
    email: j['email'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
  };
}
