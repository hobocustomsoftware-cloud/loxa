class Module {
  final String id, title;
  final String? description;
  Module({required this.id, required this.title, this.description});
  factory Module.fromJson(Map<String, dynamic> j) => Module(
    id: '${j['id'] ?? j['uuid'] ?? j['pk']}',
    title: j['title'] ?? 'Module',
    description: j['description'],
  );
}
