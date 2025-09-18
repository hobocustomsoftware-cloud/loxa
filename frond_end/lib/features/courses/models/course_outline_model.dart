int _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

class Asset {
  final int id;
  final String title;
  final String kind;
  final bool isPreview;

  Asset({
    required this.id,
    required this.title,
    required this.kind,
    this.isPreview = false,
  });

  factory Asset.fromJson(Map<String, dynamic> j) => Asset(
        id: _asInt(j['id']),
        title: j['title'] ?? 'Asset',
        kind: j['kind'] ?? 'file',
        isPreview: j['is_preview'] == true,
      );
}

class Lesson {
  final int id;
  final String title;
  final bool isPreview;
  final List<Asset> assets;

  Lesson({
    required this.id,
    required this.title,
    this.isPreview = false,
    required this.assets,
  });

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: _asInt(j['id']),
        title: j['title'] ?? 'Lesson',
        isPreview: j['is_preview'] == true,
        assets: (j['assets'] as List? ?? [])
            .map((a) => Asset.fromJson(Map<String, dynamic>.from(a)))
            .toList(),
      );
}

class Module {
  final int id;
  final String title;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory Module.fromJson(Map<String, dynamic> j) => Module(
        id: _asInt(j['id']),
        title: j['title'] ?? 'Module',
        lessons: (j['lessons'] as List? ?? [])
            .map((l) => Lesson.fromJson(Map<String, dynamic>.from(l)))
            .toList(),
      );
}

class CourseOutline {
  final int id;
  final String title;
  final String? description;
  final List<Module> modules;

  CourseOutline({
    required this.id,
    required this.title,
    this.description,
    required this.modules,
  });

  factory CourseOutline.fromJson(Map<String, dynamic> j) => CourseOutline(
        id: _asInt(j['id']),
        title: j['title'] ?? 'Course',
        description: j['description'],
        modules: (j['modules'] as List? ?? [])
            .map((m) => Module.fromJson(Map<String, dynamic>.from(m)))
            .toList(),
      );
}
