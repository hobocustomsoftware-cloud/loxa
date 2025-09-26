import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/api/dio_client.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DioClient.instance.setupInterceptors();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController()..boot(),
      child: const LoxaApp(),
    ),
  );
}

class LoxaApp extends StatefulWidget {
  const LoxaApp({super.key});
  @override
  State<LoxaApp> createState() => _LoxaAppState();
}

class _LoxaAppState extends State<LoxaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>(); // read only
    _router = buildRouter(auth); // refreshListenable: auth
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Loxa',
      routerConfig: _router,
    );
  }
}
