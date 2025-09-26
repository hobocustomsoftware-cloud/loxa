// lib/features/dashboards/admin/ui/layout/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../auth/controllers/auth_controller.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  bool _isSel(BuildContext c, String path) {
    final loc = GoRouterState.of(c).matchedLocation; // path only
    return loc == path || loc.startsWith('$path/');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LEFT: Sidebar
          SizedBox(
            width: 220,
            child: Material(
              color: const Color(0xFF0E1C2F),
              child: SafeArea(
                bottom: false,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    const ListTile(
                      leading: Icon(Icons.school, color: Colors.white),
                      title: Text(
                        'Loxa LMS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _NavItem(
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      selected: _isSel(context, '/admin/dashboard'),
                      onTap: () => context.go('/admin/dashboard'),
                    ),
                    _NavItem(
                      icon: Icons.menu_book,
                      label: 'Courses',
                      selected: _isSel(context, '/admin/courses'),
                      onTap: () => context.go('/admin/courses'),
                    ),
                    _NavItem(
                      icon: Icons.videocam,
                      label: 'Live (Agora)',
                      selected: _isSel(context, '/admin/live'),
                      onTap: () => context.go('/admin/live'),
                    ),

                    _NavItem(
                      icon: Icons.people,
                      label: 'Students',
                      selected: _isSel(context, '/admin/students'),
                      onTap: () => context.go('/admin/students'),
                    ),
                    _NavItem(
                      icon: Icons.badge,
                      label: 'Instructors',
                      selected: _isSel(context, '/admin/instructors'),
                      onTap: () => context.go('/admin/instructors'),
                    ),
                    _NavItem(
                      icon: Icons.how_to_reg,
                      label: 'Enrollments',
                      selected: _isSel(context, '/admin/enrollments'),
                      onTap: () => context.go('/admin/enrollments'),
                    ),
                    _NavItem(
                      icon: Icons.payments,
                      label: 'Payments',
                      selected: _isSel(context, '/admin/payments'),
                      onTap: () => context.go('/admin/payments'),
                    ),
                    _NavItem(
                      icon: Icons.bar_chart,
                      label: 'Reports',
                      selected: _isSel(context, '/admin/reports'),
                      onTap: () => context.go('/admin/reports'),
                    ),
                    _NavItem(
                      icon: Icons.settings,
                      label: 'Settings',
                      selected: _isSel(context, '/admin/settings'),
                      onTap: () => context.go('/admin/settings'),
                    ),
                    const Divider(
                      color: Colors.white24,
                      height: 24,
                      indent: 12,
                      endIndent: 12,
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        await context.read<AuthController>().logout();
                        if (context.mounted) context.go('/admin/signin');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // RIGHT: Topbar + Content
          Expanded(
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: cs.outlineVariant,
                          width: 0.7,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search…',
                              isDense: true,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.notifications_none),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white10 : Colors.transparent;
    final fg = Colors.white.withOpacity(selected ? 1 : 0.92);

    return InkWell(
      onTap: () {
        debugPrint('NAV TAP -> $label'); // ✅ confirm tap
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(color: fg)),
            ),
          ],
        ),
      ),
    );
  }
}
