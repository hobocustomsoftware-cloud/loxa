// app_router.dart (fixed)

import 'package:frond_end/features/courses/ui/courses_page.dart';
import 'package:frond_end/features/dashboards/admin/ui/pages/course_detail_page.dart';
import 'package:frond_end/features/dashboards/student/ui/pages/student_dashboard.dart';
// import 'package:frond_end/features/live/ui/live_session_page.dart'; // ⛔️ unused, remove
import 'package:go_router/go_router.dart';

import 'features/dashboards/admin/ui/layout/admin_shell.dart';
import 'features/dashboards/admin/ui/pages/admin_dashboard_page.dart';
import 'features/dashboards/admin/ui/pages/admin_live_sessions_page.dart'; // ✅ used

import 'features/dashboards/admin/ui/pages/enrollments_page.dart';
import 'features/dashboards/admin/ui/pages/instructors_page.dart';
import 'features/dashboards/admin/ui/pages/payments_page.dart';
import 'features/dashboards/admin/ui/pages/reports_page.dart';
import 'features/dashboards/admin/ui/pages/settings_page.dart';
import 'features/dashboards/admin/ui/pages/students_page.dart';

import 'features/dashboards/student/ui/layout/student_shell.dart';
import 'features/dashboards/student/ui/pages/student_live_sessions_page.dart';
import 'features/home/home_page.dart';
import 'features/auth/ui/admin_signin_page.dart';
import 'features/auth/controllers/auth_controller.dart';

import 'features/live/ui/session_live_page.dart'; // ✅ this is the one we use

GoRouter buildRouter(AuthController auth) => GoRouter(
  refreshListenable: auth,
  debugLogDiagnostics: true,

  redirect: (context, state) {
    // normalize trailing slash
    final uri = state.uri;
    if (uri.path.length > 1 && uri.path.endsWith('/')) {
      final trimmed = uri.path.replaceAll(RegExp(r'/+$'), '');
      return Uri(
        path: trimmed,
        queryParameters: uri.queryParameters.isEmpty
            ? null
            : uri.queryParameters,
        fragment: uri.fragment.isEmpty ? null : uri.fragment,
      ).toString();
    }

    // ------- guards -------
    if (!auth.isReady) return null;

    final path = uri.path;
    final onAdmin = path.startsWith('/admin');
    final onStudent = path.startsWith('/student');
    final onLive = path.startsWith('/live'); // ✅ live room guard (optional)
    final loggingIn = path == '/admin/signin';

    final loggedIn = auth.isLoggedIn;
    final admin = auth.isAdmin;

    if (!loggedIn && (onAdmin || onStudent || onLive)) {
      return '/admin/signin';
    }

    if (onAdmin) {
      if (!admin && !loggingIn) return '/admin/signin';
      if (admin && loggingIn) return '/admin/dashboard';
    }

    if (onStudent &&
        !(auth.isStudent || auth.isTeacher || auth.isParent || admin)) {
      return '/';
    }

    return null;
  },

  routes: [
    GoRoute(path: '/', name: 'home', builder: (_, __) => const HomePage()),
    GoRoute(
      path: '/admin/signin',
      name: 'admin_signin',
      builder: (_, __) => const AdminSignInPage(),
    ),

    // 🧱 Admin shell
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(path: '/admin', redirect: (_, __) => '/admin/dashboard'),

        GoRoute(
          path: '/admin/dashboard',
          name: 'admin_dashboard',
          builder: (_, __) => const AdminDashboardPage(),
        ),

        // ✅ Admin live list (missing before)
        GoRoute(
          path: '/admin/live',
          name: 'admin_live',
          builder: (_, __) => const AdminLiveSessionsPage(),
        ),

        // ✅ LIST (must exist for /admin/courses)
        GoRoute(
          path: '/admin/courses',
          name: 'admin_courses',
          builder: (_, __) => const CoursesPage(),
        ),

        // ✅ DETAIL
        GoRoute(
          path: '/admin/courses/:id',
          name: 'admin_course_detail',
          builder: (_, state) =>
              CourseDetailPage(id: state.pathParameters['id']!),
        ),

        GoRoute(
          path: '/admin/students',
          name: 'admin_students',
          builder: (_, __) => const StudentsPage(),
        ),
        GoRoute(
          path: '/admin/instructors',
          name: 'admin_instructors',
          builder: (_, __) => const InstructorsPage(),
        ),
        GoRoute(
          path: '/admin/enrollments',
          name: 'admin_enrollments',
          builder: (_, __) => const EnrollmentsPage(),
        ),
        GoRoute(
          path: '/admin/payments',
          name: 'admin_payments',
          builder: (_, __) => const PaymentsPage(),
        ),
        GoRoute(
          path: '/admin/reports',
          name: 'admin_reports',
          builder: (_, __) => const ReportsPage(),
        ),
        GoRoute(
          path: '/admin/settings',
          name: 'admin_settings',
          builder: (_, __) => const SettingsPage(),
        ),
      ],
    ),

    // 🧱 Student shell
    ShellRoute(
      builder: (context, state, child) => StudentShell(child: child),
      routes: [
        GoRoute(path: '/student', redirect: (_, __) => '/student/dashboard'),
        GoRoute(
          path: '/student/dashboard',
          name: 'student_dashboard',
          builder: (_, __) => const StudentDashboardPage(),
        ),
        GoRoute(
          path: '/student/live',
          name: 'student_live',
          builder: (_, __) => const StudentLiveSessionsPage(),
        ),
      ],
    ),

    // 🎥 Live room (shared)
    GoRoute(
      path: '/live/session/:id',
      name: 'live_session',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        final asHost = (state.uri.queryParameters['role'] == 'host');
        return SessionLivePage(sessionId: id, asHost: asHost);
      },
    ),
  ],
);
