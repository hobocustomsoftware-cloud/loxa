// lib/features/auth/models/me.dart
class Me {
  final int id;
  final String email;
  final String? username;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final bool isSuperuser;
  final bool isStaff;
  final bool isAdmin; // ← server or computed admin
  final List<String> roles;

  const Me({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.firstName,
    this.lastName,
    this.isSuperuser = false,
    this.isStaff = false,
    required this.isAdmin,
    required this.roles,
  });

  factory Me.fromJson(Map<String, dynamic> j) {
    bool b(v) => v == true || v == 1 || v == 'true' || v == 'True';

    final roles =
        (j['roles'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];

    final staff = b(j['isStaff'] ?? j['is_staff']);
    final superuser = b(j['isSuperuser'] ?? j['is_superuser']);
    final apiAdmin = b(j['isAdmin'] ?? j['is_admin']);

    final admin =
        apiAdmin ||
        staff ||
        superuser ||
        roles.contains('admin') ||
        roles.contains('super_admin');

    return Me(
      id: (j['id'] as num).toInt(),
      email: (j['email'] as String?) ?? '',
      isStaff: staff,
      isSuperuser: superuser,
      isAdmin: admin,
      roles: roles,
    );
  }

  // ---- role helpers (frontend အတွက်သုံးမယ့် sugar) ----
  bool hasRole(String r) => roles.contains(r);
  bool hasAny(Iterable<String> rs) => rs.any(roles.contains);
  bool hasAll(Iterable<String> rs) => rs.every(roles.contains);
}
