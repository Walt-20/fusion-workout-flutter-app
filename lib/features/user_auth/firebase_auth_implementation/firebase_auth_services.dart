// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/entry.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/event.dart';

import 'auth_page.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    print("Signing up with email and password");
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = credential.user;
      print("User created with uid: " + user!.uid);
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

  void writeEntryToFirebase(Entry entry) {
    FirebaseFirestore.instance.collection('Users').add(<String, String>{
      'username': entry.username,
      'email': entry.email,
      'name': entry.name,
      'phoneNumber': entry.phoneNumber,
      'age': entry.age,
      'weight': entry.weight,
      'height': entry.height,
      'availability': entry.availability,
    });
  }

  Future<void> writeEventToFirestore(
      String userId, Map<DateTime, List<Event>> events) async {
    final userEventsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('events');

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      events.forEach((date, eventList) {
        eventList.forEach((event) {
          final eventRef = userEventsCollection.doc(date.toIso8601String());
          batch.set(
              eventRef,
              {
                'name': event.name,
                'workouts': event.workouts.map((w) => w.toMap()).toList(),
              },
              SetOptions(merge: true));
        });
      });
      await batch.commit();
    } catch (e) {
      print("Error saving events: $e");
    }
  }

  Future<Map<DateTime, List<Event>>> fetchEvents(String userId) async {
    final userEventsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('events');
    Map<DateTime, List<Event>> events = {};

    try {
      final querySnapshot = await userEventsCollection.get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final date = DateTime.parse(doc.id);

        if (data != null && data['workouts'] != null) {
          final eventList =
              (data['workouts'] as List).map((e) => Event.fromMap(e)).toList();
        }
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
    return events;
  }

  void signOut(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
