// import 'package:dio/dio.dart';
// import '../../../core/api/dio_client.dart';

// class CourseTreeRepository {
//   final Dio _dio = DioClient.instance.dio;

//   /// One-shot: Course -> Modules -> Lessons -> Assets (compose from flat endpoints)
//   Future<Course> fetchTree(int id) async {
//     // 1) Base course detail
//     final baseResp = await _dio.get(
//       '/courses/$id/',
//       queryParameters: {'format': 'json'},
//     );
//     final base = Course.fromJson(Map<String, dynamic>.from(baseResp.data));

//     // 2) Modules for the course
//     final modules = await _fetchModules(id);

//     // 3) Fill lessons & assets
//     final filledModules = <Module>[];
//     for (final m in modules) {
//       final lessons = await _fetchLessons(m.id);

//       final filledLessons = <Lesson>[];
//       for (final l in lessons) {
//         final assets = await _fetchAssets(l.id);
//         // Asset model uses `kind` (not `type`) in UI later; here we just pass through
//         filledLessons.add(Lesson(id: l.id, title: l.title, assets: assets));
//       }

//       filledModules.add(
//         Module(id: m.id, title: m.title, lessons: filledLessons),
//       );
//     }

//     // 4) Return a new Course including composed modules
//     return Course(
//       id: base.id,
//       title: base.title,
//       description: base.description,
//       code: base.code,
//       paperNo: base.paperNo,
//       org: base.org,
//       orgName: base.orgName,
//       level: base.level,
//       owner: base.owner,
//       levelLabel: base.levelLabel,
//       programLabel: base.programLabel,
//       modules: filledModules,
//     );
//   }

//   // --- helpers --------------------------------------------------------------

//   Future<List<Module>> _fetchModules(int courseId) async {
//     final resp = await _dio.get(
//       '/modules/',
//       queryParameters: {
//         'course': courseId,
//         'format': 'json',
//         'page_size': 1000, // if pagination supported
//       },
//     );

//     final data = resp.data;
//     final list = (data is Map && data['results'] is List)
//         ? data['results'] as List
//         : (data as List);
//     return list
//         .map((e) => Module.fromJson(Map<String, dynamic>.from(e)))
//         .toList();
//   }

//   Future<List<Lesson>> _fetchLessons(int moduleId) async {
//     final resp = await _dio.get(
//       '/lessons/',
//       queryParameters: {
//         'module': moduleId,
//         'format': 'json',
//         'page_size': 1000,
//       },
//     );

//     final data = resp.data;
//     final list = (data is Map && data['results'] is List)
//         ? data['results'] as List
//         : (data as List);
//     return list
//         .map((e) => Lesson.fromJson(Map<String, dynamic>.from(e)))
//         .toList();
//   }

//   Future<List<Asset>> _fetchAssets(int lessonId) async {
//     final resp = await _dio.get(
//       '/assets/',
//       queryParameters: {
//         'lesson': lessonId,
//         'format': 'json',
//         'page_size': 1000,
//       },
//     );

//     final data = resp.data;
//     final list = (data is Map && data['results'] is List)
//         ? data['results'] as List
//         : (data as List);
//     return list
//         .map((e) => Asset.fromJson(Map<String, dynamic>.from(e)))
//         .toList();
//   }
// }
