import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final Widget? sideNav; // optional sidebar/nav-rail
  const AppShell({super.key, required this.child, this.sideNav});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final useRail = w >= 1000; // wide => show side nav
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (useRail && sideNav != null)
              SizedBox(width: 260, child: sideNav!),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
