// features/courses/models/course_summary_model.dart
class CourseSummary {
  final int id;
  final String title;
  final String description;
  final String? levelLabel;
  final String? programLabel;

  CourseSummary({
    required this.id,
    required this.title,
    this.description = '',
    this.levelLabel,
    this.programLabel,
  });

  factory CourseSummary.fromJson(Map<String, dynamic> j) => CourseSummary(
    id: j['id'] as int,
    title: (j['title'] ?? '') as String,
    description: (j['description'] ?? '') as String,
    levelLabel: j['level_label'] as String?,
    programLabel: j['program_label'] as String?,
  );
}

// class CourseSummary {
//   final int id;
//   final String title;
//   final String? code;

//   CourseSummary({required this.id, required this.title, this.code});

//   factory CourseSummary.fromJson(Map<String, dynamic> json) {
//     return CourseSummary(
//       id: json['id'] as int,
//       title: json['title'] as String,
//       code: json['code'] as String?,
//     );
//   }
// }
