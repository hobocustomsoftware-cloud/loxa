// lib/features/courses/ui/course_detail_page.dart
import 'package:flutter/material.dart';

class CourseDetailPage extends StatelessWidget {
  final String id;
  const CourseDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CourseVM>(
      future: _fetchCourseVM(id),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final vm = snap.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(vm.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              if (vm.coverUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    vm.coverUrl!,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Course ID: ${vm.id}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(vm.description ?? 'No description'),
            ],
          ),
        );
      },
    );
  }
}

// Admin-side lightweight VM (shared domain model မထိ)
class _CourseVM {
  final String id;
  final String title;
  final String? coverUrl;
  final String? description;
  _CourseVM({
    required this.id,
    required this.title,
    this.coverUrl,
    this.description,
  });
}

// TODO: replace with real Admin repo call
Future<_CourseVM> _fetchCourseVM(String id) async {
  await Future.delayed(const Duration(milliseconds: 250));
  return _CourseVM(
    id: id,
    title: 'Course $id',
    coverUrl: null,
    description: 'Placeholder description for $id.',
  );
}
