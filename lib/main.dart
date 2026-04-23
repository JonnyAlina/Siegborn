import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cross_platform_app/core/theme/app_theme.dart';
import 'package:cross_platform_app/features/auth/presentation/auth_gate.dart';
import 'package:cross_platform_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CrossPlatformApp());
}

class CrossPlatformApp extends StatelessWidget {
  const CrossPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siegeborn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

