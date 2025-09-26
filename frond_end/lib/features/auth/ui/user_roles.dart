// lib/core/auth/user_roles.dart

class UserRoles {
  final Set<String> global; // e.g., {'admin','student'}
  final Map<int, Set<String>> org; // e.g., {1: {'org_admin','teacher'}}

  const UserRoles({this.global = const {}, this.org = const {}});

  factory UserRoles.fromJwt(Map<String, dynamic> payload) {
    final g = (payload['roles'] as List?)?.cast<String>().toSet() ?? {};
    final m = <int, Set<String>>{};
    final raw = payload['org_roles'] as Map? ?? {};
    raw.forEach((k, v) {
      final id = int.tryParse('$k');
      if (id != null) m[id] = (v as List).cast<String>().toSet();
    });
    return UserRoles(global: g, org: m);
  }

  bool has(String r) => global.contains(r);
  bool hasInOrg(int orgId, String r) => org[orgId]?.contains(r) ?? false;
}
