import 'package:flutter/material.dart';
import 'package:frond_end/features/courses/models/course_summary_model.dart';

class CourseCard extends StatelessWidget {
  final CourseSummary course;
  final VoidCallback? onTap;
  const CourseCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              if ((course.programLabel ?? '').isNotEmpty)
                Text(
                  course.programLabel!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              const Spacer(),
              Text('#${course.id}'),
            ],
          ),
        ),
      ),
    );
  }
}
