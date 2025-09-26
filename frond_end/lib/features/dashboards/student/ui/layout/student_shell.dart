import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentShell extends StatelessWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  bool _sel(BuildContext c, String p) =>
      GoRouterState.of(c).uri.toString().startsWith(p);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: const Color(0xFF122033),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const ListTile(
                  title: Text(
                    'Student',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Icon(Icons.school, color: Colors.white),
                ),
                _Nav(
                  label: 'Dashboard',
                  icon: Icons.dashboard,
                  selected: _sel(context, '/student/dashboard'),
                  onTap: () => context.go('/student/dashboard'),
                ),
                _Nav(
                  label: 'Live Sessions',
                  icon: Icons.videocam,
                  selected: _sel(context, '/student/live'),
                  onTap: () => context.go('/student/live'),
                ),
                const Spacer(),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: SafeArea(child: child)),
        ],
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _Nav({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white10 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(.9)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
