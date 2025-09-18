// lib/features/courses/models/curriculum_models.dart
class Curriculum {
  final CourseSummary course;
  final List<ModuleM> modules;
  Curriculum({required this.course, required this.modules});

  factory Curriculum.fromJson(Map<String, dynamic> j) => Curriculum(
    course: CourseSummary.fromJson(Map<String, dynamic>.from(j['course'])),
    modules: (j['modules'] as List? ?? [])
        .map((e) => ModuleM.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class CourseSummary {
  final int id;
  final String title;
  final String description;
  CourseSummary({
    required this.id,
    required this.title,
    required this.description,
  });
  factory CourseSummary.fromJson(Map<String, dynamic> j) => CourseSummary(
    id: j['id'],
    title: j['title'] ?? '',
    description: j['description'] ?? '',
  );
}

class ModuleM {
  final int id;
  final String title;
  final List<LessonM> lessons;
  ModuleM({required this.id, required this.title, required this.lessons});
  factory ModuleM.fromJson(Map<String, dynamic> j) => ModuleM(
    id: j['id'],
    title: j['title'] ?? '',
    lessons: (j['lessons'] as List? ?? [])
        .map((e) => LessonM.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class LessonM {
  final int id;
  final String title;
  final bool isPreview;
  final bool published;
  final List<AssetM> assets;
  LessonM({
    required this.id,
    required this.title,
    required this.isPreview,
    required this.published,
    required this.assets,
  });
  factory LessonM.fromJson(Map<String, dynamic> j) => LessonM(
    id: j['id'],
    title: j['title'] ?? '',
    isPreview: j['is_preview'] ?? false,
    published: j['published'] ?? false,
    assets: (j['assets'] as List? ?? [])
        .map((e) => AssetM.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class AssetM {
  final int id;
  final String title;
  final String kind; // 'PDF' | 'VIDEO' | 'RECORDING'
  final String? file;
  final String? url;
  final int? sizeBytes;
  final bool isPreview;
  final bool published;
  AssetM({
    required this.id,
    required this.title,
    required this.kind,
    this.file,
    this.url,
    this.sizeBytes,
    required this.isPreview,
    required this.published,
  });
  factory AssetM.fromJson(Map<String, dynamic> j) => AssetM(
    id: j['id'],
    title: j['title'] ?? '',
    kind: (j['kind'] ?? j['type'] ?? '').toString(),
    file: j['file'],
    url: j['url'],
    sizeBytes: j['size_bytes'],
    isPreview: j['is_preview'] ?? false,
    published: j['published'] ?? false,
  );
}
