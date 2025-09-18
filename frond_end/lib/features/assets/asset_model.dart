int _asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ""}') ?? 0;
bool _asBool(dynamic v) => v == true || v?.toString() == 'true';

class LessonAssetModel {
  final int id;
  final int lessonId;
  final String title;
  final String kind; // file | image | link | video ...
  final String? file; // backend absolute/relative URL
  final String? url; // external
  final int sizeBytes;
  final bool isPreview;
  final bool published;

  LessonAssetModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.kind,
    this.file,
    this.url,
    required this.sizeBytes,
    required this.isPreview,
    required this.published,
  });

  factory LessonAssetModel.fromJson(Map<String, dynamic> j) => LessonAssetModel(
    id: _asInt(j['id']),
    lessonId: _asInt(j['lesson']),
    title: j['title'] ?? 'Asset',
    kind: j['kind']?.toString() ?? 'file',
    file: j['file'] as String?,
    url: j['url'] as String?,
    sizeBytes: _asInt(j['size_bytes']),
    isPreview: _asBool(j['is_preview']),
    published: _asBool(j['published']),
  );
}
