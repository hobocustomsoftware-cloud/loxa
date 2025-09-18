// features/courses/models/course_meta_model.dart
class CourseMeta {
  final int id;
  final String title;
  final String description;
  final String? code;
  final String? paperNo;
  final int? org;
  final int? level;
  final int? owner;
  final String? levelLabel;
  final String? programLabel;

  CourseMeta({
    required this.id,
    required this.title,
    this.description = '',
    this.code,
    this.paperNo,
    this.org,
    this.level,
    this.owner,
    this.levelLabel,
    this.programLabel,
  });

  factory CourseMeta.fromJson(Map<String, dynamic> j) {
    if (!j.containsKey('id')) {
      // server error JSON (e.g. {"detail": "..."}), don't try to parse
      throw FormatException('CourseMeta JSON missing id');
    }
    return CourseMeta(
      id: j['id'] is int ? j['id'] as int : int.parse('${j['id']}'),
      title: (j['title'] ?? '') as String,
      description: (j['description'] ?? '') as String,
      code: j['code'] as String?,
      paperNo: j['paper_no'] as String?,
      org: j['org'] as int?, // can be null
      level: j['level'] as int?, // number
      owner: j['owner'] as int?, // can be null
      levelLabel: j['level_label'] as String?,
      programLabel: j['program_label'] as String?,
    );
  }
}
