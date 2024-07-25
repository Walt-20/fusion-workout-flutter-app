// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/entry.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/event.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/workouts.dart';

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

  Future<void> deleteEventsFromFirestore(
      DateTime eventToDelete, String eventName) async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    final userEventsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('events');

    try {
      String docId = eventToDelete.toIso8601String();

      final querySnapshot = await userEventsCollection
          .where('date', isEqualTo: docId)
          .where('name', isEqualTo: eventName)
          .get();

      debugPrint('There is a querySnapshot $querySnapshot');

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshot.docs) {
        debugPrint('there is a doc $doc');
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print("Error removing event: $e");
    }
  }

  Future<Map<DateTime, List<Event>>> fetchEventsFromFirestore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final userEventsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('events');

    try {
      final snapshot = await userEventsCollection.get();
      final Map<DateTime, List<Event>> fetchedEvents = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = DateTime.parse(data['date']);
        final eventName = data['name'] as String;
        final workoutsData = data['workouts'] as List<dynamic>? ?? [];

        // Parse workouts
        final workouts = workoutsData.map((w) {
          final workoutData = w as Map<String, dynamic>;
          // Assuming there's a method to parse workout data into Workout objects
          return Workout.fromMap(workoutData);
        }).toList();

        // Create an Event object (assuming there's a constructor that takes the name and workouts)
        final event = Event(name: eventName, workouts: workouts);

        // Group events by date
        if (!fetchedEvents.containsKey(date)) {
          fetchedEvents[date] = [];
        }
        fetchedEvents[date]!.add(event);
      }

      return fetchedEvents;
    } catch (e) {
      print("Error fetching events: $e");
      return {};
    }
  }

  Future<void> deleteWorkoutFromFirestore(String eventName,
      DateTime eventHoldingWorkout, Workout workoutToDelete) async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    final eventCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('events');

    try {
      String eventDocId = eventHoldingWorkout.toIso8601String();
      debugPrint("event doc id is $eventDocId");

      final querySnapshot = await eventCollection
          .where('date', isEqualTo: eventDocId)
          .where('name', isEqualTo: eventName)
          .get();

      // Fetch the event document
      debugPrint("event doc is $querySnapshot");
      if (querySnapshot.docs.isNotEmpty) {
        debugPrint("the doc exists");

        final eventDoc = querySnapshot.docs.first;
        // Get the workouts array from the document data
        List<dynamic> workouts = eventDoc.data()['workouts'] ?? [];

        // Convert to list of Workout objects
        List<Workout> workoutList =
            workouts.map((w) => Workout.fromMap(w)).toList();

        // Remove the specific workout based on exercise (assuming 'exercise' is unique)
        workoutList.removeWhere((w) => w.exercise == workoutToDelete.exercise);

        // Convert back to list of maps
        List<Map<String, dynamic>> updatedWorkouts =
            workoutList.map((w) => w.toMap()).toList();

        debugPrint("update workoutlist $updatedWorkouts");

        // Update the document with the modified workouts array
        await eventDoc.reference.update({'workouts': updatedWorkouts});
      }
    } catch (e) {
      print("Error removing workout: $e");
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
