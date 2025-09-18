class Lesson {
  final String id, title;
  final String? summary;
  Lesson({required this.id, required this.title, this.summary});
  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
    id: '${j['id'] ?? j['uuid'] ?? j['pk']}',
    title: j['title'] ?? 'Lesson',
    summary: j['summary'] ?? j['description'],
  );
}
