// lib/features/orgs/data/org_repository.dart
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';

class Org {
  final int id;
  final String name;
  final String? type;
  Org({required this.id, required this.name, this.type});

  factory Org.fromJson(Map<String, dynamic> j) =>
      Org(id: j['id'], name: j['name'] ?? '', type: j['type']);
}

class OrgRepository {
  final _dio = DioClient.instance.dio;

  Future<List<Org>> list({String? search}) async {
    final r = await _dio.get(
      '/orgs/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final results = (r.data['results'] as List).cast<Map<String, dynamic>>();
    return results.map(Org.fromJson).toList();
  }

  Future<Org> create({required String name, String? type}) async {
    final r = await _dio.post('/orgs/', data: {'name': name, 'type': type});
    return Org.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/orgs/$id/');
  }
}
