// lib/features/dashboards/common/side_menu.dart
final menuByRole = {
  'admin': [
    ('/admin/users', 'Users'),
    ('/admin/courses', 'Courses'),
    ('/admin/sessions', 'Live Sessions'),
  ],
  'org_admin': [
    ('/org-admin/overview', 'Overview'),
    ('/org-admin/teachers', 'Teachers'),
    ('/org-admin/courses', 'Courses'),
    ('/org-admin/sessions', 'Sessions'),
  ],
  // … etc
};
