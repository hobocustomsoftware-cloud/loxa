import 'package:jwt_decoder/jwt_decoder.dart';

class UserRoles {
  final bool isAdmin;
  final bool isTeacher;
  final bool isModerator;
  final bool isStudent;
  final bool isParent;

  const UserRoles({
    this.isAdmin = false,
    this.isTeacher = false,
    this.isModerator = false,
    this.isStudent = false,
    this.isParent = false,
  });

  static UserRoles fromAccess(String token) {
    try {
      final m = JwtDecoder.decode(token);
      final roles = (m['roles'] as List?)?.cast<String>() ?? [];
      bool has(String r) => roles.contains(r);
      return UserRoles(
        isAdmin: has('admin'),
        isTeacher: has('teacher'),
        isModerator: has('moderator'),
        isStudent: has('student'),
        isParent: has('parent'),
      );
    } catch (_) {
      return const UserRoles();
    }
  }
}
