// lib/features/courses/models/course_model.dart
class CourseSummary {
  final int id;
  final String title;
  final String? code;
  final String? paperNo;
  final int? org;
  final int? level;
  final int? owner;
  final String? levelLabel;
  final String? programLabel;
  final String? description;

  CourseSummary({
    required this.id,
    required this.title,
    this.code,
    this.paperNo,
    this.org,
    this.level,
    this.owner,
    this.levelLabel,
    this.programLabel,
    this.description,
  });

  factory CourseSummary.fromJson(Map<String, dynamic> j) => CourseSummary(
    id: j['id'] as int,
    title: j['title'] ?? '',
    code: j['code'],
    paperNo: j['paper_no'],
    org: j['org'],
    level: j['level'],
    owner: j['owner'],
    levelLabel: j['level_label'],
    programLabel: j['program_label'],
    description: j['description'],
  );
}
