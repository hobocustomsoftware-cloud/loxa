import 'package:flutter/material.dart';
import 'app_router.dart';
import 'core/api/dio_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DioClient.instance.setupInterceptors(); // add X-Org-ID header globally
  runApp(const LoxaApp());
}

class LoxaApp extends StatelessWidget {
  const LoxaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Loxa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F62FE)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
