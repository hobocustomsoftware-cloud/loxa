class AdminCourse {
  final int id;
  final String title;
  final String? description;
  final String? code;
  final String? levelLabel;
  final String? programLabel;

  AdminCourse({
    required this.id,
    required this.title,
    this.description,
    this.code,
    this.levelLabel,
    this.programLabel,
  });

  factory AdminCourse.fromJson(Map<String, dynamic> j) => AdminCourse(
    id: j['id'],
    title: j['title'] ?? '',
    description: j['description'],
    code: j['code'],
    levelLabel: j['level_label'],
    programLabel: j['program_label'],
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    if (code != null) 'code': code,
  };
}
