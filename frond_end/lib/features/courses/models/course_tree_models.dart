// features/courses/models/course_tree_models.dart
class CourseTree {
  final int id;
  final String title;
  final List<ModuleItem> modules;
  CourseTree({required this.id, required this.title, required this.modules});

  factory CourseTree.fromJson(Map<String, dynamic> j) => CourseTree(
    id: j['id'] as int,
    title: (j['title'] ?? '') as String,
    modules: ((j['modules'] ?? []) as List)
        .map((e) => ModuleItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class ModuleItem {
  final int id;
  final String title;
  final List<LessonItem> lessons;
  ModuleItem({required this.id, required this.title, required this.lessons});

  factory ModuleItem.fromJson(Map<String, dynamic> j) => ModuleItem(
    id: j['id'] as int,
    title: (j['title'] ?? '') as String,
    lessons: ((j['lessons'] ?? []) as List)
        .map((e) => LessonItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class LessonItem {
  final int id;
  final String title;
  final List<AssetItem> assets;
  LessonItem({required this.id, required this.title, required this.assets});

  factory LessonItem.fromJson(Map<String, dynamic> j) => LessonItem(
    id: j['id'] as int,
    title: (j['title'] ?? '') as String,
    assets: ((j['assets'] ?? []) as List)
        .map((e) => AssetItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class AssetItem {
  final int id;
  final String type; // PDF | VIDEO | RECORDING
  final bool isPreview; // if server returns it; default false
  final String? file; // relative e.g. /media/...
  final String? absUrl; // absolute e.g. http://...

  AssetItem({
    required this.id,
    required this.type,
    required this.isPreview,
    this.file,
    this.absUrl,
  });

  factory AssetItem.fromJson(Map<String, dynamic> j) => AssetItem(
    id: j['id'] as int,
    type: (j['type'] ?? '') as String,
    isPreview: (j['is_preview'] ?? false) as bool,
    file: j['file'],
    absUrl: j['abs_url'],
  );
  String? get playableUrl => (absUrl?.isNotEmpty ?? false) ? absUrl : file;
}
