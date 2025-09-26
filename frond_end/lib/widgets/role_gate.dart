// lib/widgets/role_gate.dart
import 'package:flutter/widgets.dart';
import '../features/auth/ui/auth_store.dart';

class RoleGate extends StatelessWidget {
  final Widget child;
  final List<String> anyOfGlobal;
  final List<String> anyOfOrg;
  const RoleGate({
    super.key,
    required this.child,
    this.anyOfGlobal = const [],
    this.anyOfOrg = const [],
  });

  @override
  Widget build(BuildContext context) {
    final a = AuthStore.I;
    bool ok = false;
    if (anyOfGlobal.isNotEmpty) {
      ok |= anyOfGlobal.any((r) => a.roles.global.contains(r));
    }
    if (anyOfOrg.isNotEmpty && a.selectedOrgId != null) {
      ok |= anyOfOrg.any((r) => a.roles.org[a.selectedOrgId!]!.contains(r));
    }
    return ok ? child : const SizedBox.shrink();
  }
}
