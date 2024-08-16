// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/auth_page.dart';
import 'package:fusion_workouts/features/user_auth/provider/tokenprovider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Failed to initalize Firebase: $e');
  }
  runApp(const MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TokenProvider>(
      create: (context) => TokenProvider(),
      child: const MaterialApp(
        title: 'Fusion Workouts App',
        debugShowCheckedModeBanner: true,
        home: AuthPage(),
      ),
    );
  }
}
