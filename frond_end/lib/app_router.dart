import 'package:flutter/material.dart';
import 'package:frond_end/features/live/ui/live_session_page.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_page.dart';
import 'features/courses/ui/course_detail_page.dart';

// app_router.dart
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
      routes: [
        GoRoute(
          path: 'courses/:id',
          builder: (ctx, st) {
            final raw = st.pathParameters['id'];
            final id = int.tryParse(raw!);
            return CourseDetailPage(
              id: id ?? 0,
              courseId: id ?? 0,
            ); // or guard/redirect
          },
        ),
        GoRoute(
          path: 'live/:id',
          builder: (ctx, st) =>
              LiveSessionPage(sessionId: int.parse(st.pathParameters['id']!)),
        ),
      ],
    ),
  ],
);

// class _BadRoutePage extends StatelessWidget {
//   const _BadRoutePage();

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: Text('Invalid course id')));
//   }
// }
