import 'package:flutter/material.dart';

class Breakpoints {
  static const mobile = 600.0;
  static const tablet = 1024.0;
}

class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final void Function(int) onNav;
  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNav,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < Breakpoints.mobile) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onNav,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.video_camera_front_outlined),
              label: 'Sessions',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              label: 'Courses',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              label: 'Track',
            ),
          ],
        ),
      );
    } else if (w < Breakpoints.tablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onNav,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.video_camera_front_outlined),
                  label: Text('Sessions'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school_outlined),
                  label: Text('Courses'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.checklist_outlined),
                  label: Text('Track'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 280,
              child: Drawer(
                child: ListView(
                  children: [
                    const DrawerHeader(
                      child: Text('Loxa Admin', style: TextStyle(fontSize: 22)),
                    ),
                    _tile(Icons.dashboard_outlined, 'Home', 0),
                    _tile(Icons.video_camera_front_outlined, 'Sessions', 1),
                    _tile(Icons.school_outlined, 'Courses', 2),
                    _tile(Icons.checklist_outlined, 'Track', 3),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }
  }

  Widget _tile(IconData i, String t, int idx) => ListTile(
    leading: Icon(i),
    title: Text(t),
    selected: currentIndex == idx,
    onTap: () => onNav(idx),
  );
}
