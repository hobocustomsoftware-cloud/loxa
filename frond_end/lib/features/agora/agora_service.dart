import '../../core/api/dio_client.dart';
import '../../core/utils/constants.dart';

class AgoraService {
  Future<String> fetchToken(String channel) async {
    final r = await DioClient.instance.dio.post(
      Constants.agoraToken,
      data: {'channel': channel},
    );
    return r.data['token'] as String;
  }
}
