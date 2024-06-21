// ignore_for_file: prefer_final_fields

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    if (credential.user != null) {
      user = credential.user;
    } else {
      print("No User!");
    }
  }
}
