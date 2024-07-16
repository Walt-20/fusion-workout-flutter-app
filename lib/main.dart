// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/auth_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // if (kDebugMode) {
  //   try {
  //     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //     FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   } catch (e) {
  //     print('Failed to connect to the emulator: $e');
  //   }
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Fusion Workouts App',
      debugShowCheckedModeBanner: false,
      // home: SplashScreen(
      //   child: AuthPage(),
      // ),
      home: AuthPage(),
    );
  }
}
