// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/entry.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/event.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';

import 'auth_page.dart';

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
    }
  }

  void writeEntryToFirebase(Entry entry) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('userProfile')
        .doc('profileInformation')
        .set({
      'username': entry.username,
      'email': entry.email,
      'name': entry.name,
      'phoneNumber': entry.phoneNumber,
      'age': entry.age,
      'sex': entry.sex,
      'weight': entry.weight,
      'height': entry.height,
      'availability': entry.availability,
    }).then((value) {
      debugPrint("success");
    }).catchError((onError) {
      debugPrint(onError.toString());
    });
  }

  Future<void> writeEventToFirestore(String userId,
      Map<DateTime, List<Event>> events, DateTime selectedDay) async {
    final userEventsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('events');

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var entry in events.entries) {
        DateTime date = entry.key;
        List<Event> eventList = entry.value;

        for (var event in eventList) {
          final eventQuery = await userEventsCollection
              .where('name', isEqualTo: event.name)
              .where('date', isEqualTo: date.toIso8601String())
              .limit(1)
              .get();

          if (eventQuery.docs.isNotEmpty) {
            final eventDoc = eventQuery.docs.first;
            batch.set(
              eventDoc.reference,
              {
                'date': date.toIso8601String(),
                'name': event.name,
                'workouts': event.workouts.map((w) => w.toMap()).toList(),
              },
              SetOptions(merge: true),
            );
          } else {
            final eventRef = userEventsCollection.doc();
            batch.set(
              eventRef,
              {
                'date': date.toIso8601String(),
                'name': event.name,
                'workouts': event.workouts.map((w) => w.toMap()).toList(),
              },
            );
          }
        }
      }

      await batch.commit();
    } catch (e) {
      print("Error saving events: $e");
      // Handle error appropriately
      throw e; // Rethrow the error to propagate it further if needed
    }
  }

  void writeMealsToFirebase(Map<String, List<Food>> mealsByDate) async {
    final userMealCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meals');

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var mealEntry in mealsByDate.entries) {
        String date = mealEntry.key;
        List<Food> mealsList = mealEntry.value;

        // Serialize each food item to a map
        List<Map<String, dynamic>> serializedMeals = mealsList
            .map((meal) => {
                  'foodId': meal.foodId,
                  'servingId': meal.servings,
                })
            .toList();

        // Get a reference to the document
        final docRef = userMealCollection.doc(date);

        // Set the data
        batch.set(docRef, {
          'date': date,
          'meals': serializedMeals,
        });
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print("Error saving meals: $e");
      // Handle error appropriately
      throw e;
    }
  }

  void removeMealFromFirestore(Food meal, String date) async {
    final userMealsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meals')
        .doc(date);

    try {
      DocumentSnapshot mealDocSnapshot = await userMealsCollection.get();

      // Explicitly cast the data to Map<String, dynamic>
      Map<String, dynamic> mealData =
          mealDocSnapshot.data() as Map<String, dynamic>? ?? {};

      List<dynamic> mealsList = mealData['meals'] ?? [];

      // Assuming `foodId` is a property of `Food` and accessible in this context
      mealsList
          .removeWhere((dynamic mealItem) => mealItem['foodId'] == meal.foodId);

      if (mealsList.isEmpty) {
        await userMealsCollection.delete();
      } else {
        await userMealsCollection.update({'meals': mealsList});
      }
    } catch (e) {
      // Consider handling the exception or logging it for debugging purposes
    }
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
