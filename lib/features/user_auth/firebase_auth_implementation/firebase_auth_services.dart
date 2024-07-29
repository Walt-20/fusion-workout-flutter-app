// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/entry.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/event.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/exercise.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/workouts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'auth_page.dart';
import 'dart:convert';

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

  Future<void> addExerciseToFirestore(
      DateTime date, List<Map<String, dynamic>> exercises) async {
    final firestore = FirebaseFirestore.instance;

    // Format date to string
    String dateString = DateFormat('yyyy-MM-dd').format(date);

    // Reference to the document in the Firestore collection
    DocumentReference docRef = firestore
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('exercise')
        .doc(dateString);

    // Add or update the document
    await docRef.set({
      'exercises': FieldValue.arrayUnion(exercises),
    }, SetOptions(merge: true));
  }

  Future<void> updateExerciseInFirebase(
      DateTime date, List<Map<String, dynamic>> exercises) async {
    final firestore = FirebaseFirestore.instance;

    // Format date to string
    String dateString = DateFormat('yyyy-MM-dd').format(date);

    // Reference to the document in the Firestore collection
    DocumentReference docRef = firestore
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('exercise')
        .doc(dateString);

    // Get the existing document
    DocumentSnapshot docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      List<dynamic> existingExercises = docSnapshot['exercises'];

      for (var newExercise in exercises) {
        bool found = false;
        for (int i = 0; i < existingExercises.length; i++) {
          var existingExercise = existingExercises[i];
          if (existingExercise['name'] == newExercise['name'] &&
              existingExercise['muscle'] == newExercise['muscle']) {
            // Update the existing exercise
            existingExercises[i] = newExercise;
            found = true;
            break;
          }
        }
        if (!found) {
          // Add the new exercise if no match was found
          existingExercises.add(newExercise);
        }
      }

      // Update the document with the modified exercises list
      await docRef.update({'exercises': existingExercises});
    } else {
      // If the document does not exist, create it with the new exercises
      await docRef.set({'exercises': exercises});
    }
  }

  Future<void> removeExerciseFromFirebase(DateTime date, String name,
      String muscle, int? reps, int? sets, double? weight) async {
    debugPrint("made it to the auth service");
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    final firestore = FirebaseFirestore.instance;

    // Reference to the document in the Firestore collection
    DocumentReference docRef = firestore
        .collection('Users')
        .doc(userUid)
        .collection('exercise')
        .doc(dateString);

    try {
      // Get the document
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        List<dynamic> exercises = docSnapshot['exercises'];

        // Find the exercise to remove
        Map<String, dynamic>? exerciseToRemove;
        for (var exercise in exercises) {
          if (exercise['name'] == name &&
              exercise['muscle'] == muscle &&
              exercise['reps'] == reps &&
              exercise['sets'] == sets &&
              exercise['weight'] == weight) {
            exerciseToRemove = exercise;
            break;
          }
        }

        if (exerciseToRemove != null) {
          // Remove the exercise
          await docRef.update({
            'exercises': FieldValue.arrayRemove([exerciseToRemove])
          });
        }
      }
    } catch (e) {
      print("Error removing exercise: $e");
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

      final querySnapshot = await eventCollection
          .where('date', isEqualTo: eventDocId)
          .where('name', isEqualTo: eventName)
          .get();

      // Fetch the event document
      if (querySnapshot.docs.isNotEmpty) {
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

        // Update the document with the modified workouts array
        await eventDoc.reference.update({'workouts': updatedWorkouts});
      }
    } catch (e) {
      print("Error removing workout: $e");
    }
  }

  void writeMealsToFirebase(Map<String, List<FoodItem>> mealsByDate) async {
    final userMealCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meals');

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var mealEntry in mealsByDate.entries) {
        String date = mealEntry.key;
        List<FoodItem> mealsList = mealEntry.value;

        // Serialize each food item to a map
        List<Map<String, dynamic>> serializedMeals = mealsList
            .map((meal) => {
                  'foodId': meal.foodId,
                  'servings': meal.servings,
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

  void fetchFoodIdFromFirestore(String date) async {
    final userMealsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meals')
        .doc(date);

    try {
      DocumentSnapshot mealDocSnapshot = await userMealsCollection.get();

      if (mealDocSnapshot.exists) {
        Map<String, dynamic> data =
            mealDocSnapshot.data() as Map<String, dynamic>;

        List<dynamic> meals = data['meals'];

        for (var meal in meals) {
          String foodId = meal['foodId'];
          int servings = meal['servings'];

          await fetchFoodIdFromAPI(foodId);
        }
      } else {
        // Handle the case where the document does not exist
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
    }
  }

  void removeMealFromFirestore(FoodItem meal, String date) async {
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

  Future<void> fetchFoodIdFromAPI(String foodId) async {
    final url = Uri.parse('http://10.0.2.2:3000/fetch-foodId');

    try {
      final response =
          await http.get(Uri.parse('$url?searchExpression=$foodId'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
      }
    } catch (e) {}
  }
}
