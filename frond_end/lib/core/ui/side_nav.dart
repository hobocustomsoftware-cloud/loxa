import 'package:flutter/material.dart';

class SideNav extends StatelessWidget {
  final String current;
  final void Function(String route) onNavigate;
  final List<_NavItem> items;

  const SideNav({
    super.key,
    required this.current,
    required this.onNavigate,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_outlined),
              const SizedBox(width: 8),
              Text('Loxa', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          for (final it in items) _tile(context, it),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, _NavItem it) {
    final active = current == it.route;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(
        it.icon,
        color: active ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(it.label),
      selected: active,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () => onNavigate(it.route),
    );
  }
}

class _NavItem {
  final String route;
  final String label;
  final IconData icon;
  _NavItem(this.route, this.label, this.icon);
}

List<_NavItem> adminNav = [
  _NavItem('/dashboard', 'Dashboard', Icons.dashboard_outlined),
  _NavItem('/courses', 'Courses', Icons.menu_book_outlined),
  _NavItem('/live', 'Live Sessions', Icons.podcasts_outlined),
  _NavItem('/users', 'Users', Icons.people_outline),
  _NavItem('/reports', 'Reports', Icons.bar_chart_outlined),
];

List<_NavItem> teacherNav = [
  _NavItem('/dashboard', 'Dashboard', Icons.dashboard_outlined),
  _NavItem('/my-courses', 'My Courses', Icons.menu_book_outlined),
  _NavItem('/live', 'Live Sessions', Icons.podcasts_outlined),
  _NavItem('/attendance', 'Attendance', Icons.event_available_outlined),
];

List<_NavItem> studentNav = [
  _NavItem('/dashboard', 'Dashboard', Icons.dashboard_outlined),
  _NavItem('/catalog', 'Catalog', Icons.storefront_outlined),
  _NavItem('/my-learning', 'My Learning', Icons.play_circle_outline),
  _NavItem('/live', 'Live Sessions', Icons.podcasts_outlined),
];

List<_NavItem> parentNav = [
  _NavItem('/dashboard', 'Overview', Icons.hub_outlined),
  _NavItem('/children', 'Children', Icons.family_restroom_outlined),
  _NavItem('/reports', 'Reports', Icons.bar_chart_outlined),
];
