class UserMe {
  final int id;
  final String email;
  final bool isStaff;
  final bool isSuperuser;
  final String? firstName;
  final String? lastName;

  const UserMe({
    required this.id,
    required this.email,
    required this.isStaff,
    required this.isSuperuser,
    this.firstName,
    this.lastName,
  });

  factory UserMe.fromJson(Map<String, dynamic> j) => UserMe(
    id: j['id'] as int,
    email: (j['email'] ?? '') as String,
    isStaff: (j['is_staff'] ?? false) as bool,
    isSuperuser: (j['is_superuser'] ?? false) as bool,
    firstName: j['first_name'] as String?,
    lastName: j['last_name'] as String?,
  );
}
