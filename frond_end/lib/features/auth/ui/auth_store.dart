// lib/core/auth/auth_store.dart
import 'package:jwt_decoder/jwt_decoder.dart'; // or manual decoder
import 'user_roles.dart';

class AuthStore {
  static final AuthStore I = AuthStore._();
  AuthStore._();

  String? accessToken;
  int? selectedOrgId;
  UserRoles roles = const UserRoles();

  void setToken(String? token) {
    accessToken = token;
    if (token == null || token.isEmpty) {
      roles = const UserRoles();
      return;
    }
    final payload = JwtDecoder.decode(token);
    roles = UserRoles.fromJwt(payload);
  }

  bool get isLoggedIn => (accessToken ?? '').isNotEmpty;
  bool get isAdmin => roles.has('admin');
  bool get isModerator => roles.has('moderator');
  bool get isTeacher => roles.has('teacher');
  bool get isStudent => roles.has('student');
  bool get isParent => roles.has('parent');
  bool get isOrgAdmin =>
      selectedOrgId != null && roles.hasInOrg(selectedOrgId!, 'org_admin');
  bool get isOrgTeacher =>
      selectedOrgId != null && roles.hasInOrg(selectedOrgId!, 'org_teacher');
}
