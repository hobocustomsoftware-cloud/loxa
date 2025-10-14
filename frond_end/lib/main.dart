// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/dio_client.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/data/auth_repository.dart';
import 'app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) storage ထဲက tokens/me hydrate
  await AuthRepository.instance.init();

  // 2) Dio interceptors (Authorization header ထည့်)
  DioClient.instance.setupInterceptors();

  // 3) AuthController ကို create + init
  final auth = AuthController();
  await auth.init();

  runApp(
    ChangeNotifierProvider.value(
      value: auth,
      child: MyApp(auth: auth),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.auth});
  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: buildRouter(auth), // <-- GoRouter に渡す
      debugShowCheckedModeBanner: false,
    );
  }
}
