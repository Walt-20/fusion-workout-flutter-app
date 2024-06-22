// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fusion_workouts/features/app/splash_screen/splash_screen.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/auth_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/dashboard_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/on_boarding.dart';
import 'features/user_auth/presentation/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

    // options: const FirebaseOptions(
    //   apiKey: "AIzaSyBsqqDV9xOeHwyrkReKuI_szZrGabRBOU0",
    //   appId: "1:464590724690:android:ab0460ae8beb58ea4b498b",
    //   messagingSenderId: "464590724690",
    //   projectId: "fusion-workout-app",
    // ),
  );
  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      print('Failed to connect to the emulator: $e');
    }
  }
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
