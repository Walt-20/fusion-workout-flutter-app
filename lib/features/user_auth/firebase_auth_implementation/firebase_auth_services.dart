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
    debugPrint("what is the list of exercises ${exercises.toString()}");
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('exercises')
        .doc(dateString);
    await docRef.set({
      'exercises': FieldValue.arrayUnion(exercises),
    }, SetOptions(merge: true));
  }

  Future<void> updateExerciseInFirebase(
      DateTime date, Map<String, dynamic> exercise) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('exercises')
        .doc(dateString);

    final docSnapshot = await docRef.get();

    debugPrint("the doc snapshot is $docSnapshot");

    if (docSnapshot.exists) {
      debugPrint("the docSnapshot does exist");
      List<dynamic> existingExercises = docSnapshot.data()?['exercises'] ?? [];

      debugPrint("existingExercises is ${existingExercises.toString()}");

      bool found = false;
      for (var i = 0; i < existingExercises.length; i++) {
        if (existingExercises[i]['id'] == exercise['id']) {
          debugPrint("exercise is ${exercise['id']}");
          debugPrint("exercise completed is ${exercise['completed']}");
          existingExercises[i] = exercise;
          found = true;
          break;
        }
      }

      if (!found) {
        debugPrint("Exercise with id ${exercise['id']} is not found");
      } else {
        await docRef.update({'exercises': existingExercises});
      }
    }
  }

  // Future<void> updateFromSearchExerciseInFirebase(
  //     DateTime date, Map<String, dynamic> exerciseMap) async {
  //   final dateString = DateFormat('yyyy-MM-dd').format(date);
  //   final docRef = FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection('exercises')
  //       .doc(dateString);

  //   final docSnapshot = await docRef.get();

  //   if (docSnapshot.exists) {
  //     List<dynamic> existingExercisesDynamic =
  //         docSnapshot.data()?['exercises'] ?? [];
  //     List<Map<String, dynamic>> existingExercises = existingExercisesDynamic
  //         .map((e) => Map<String, dynamic>.from(e))
  //         .toList();
  //     final WriteBatch batch = FirebaseFirestore.instance.batch();

  //     for (var exercise in exerciseMap) {
  //       bool found = false;
  //       for (int i = 0; i < existingExercises.length; i++) {
  //         if (existingExercises[i]['id'] == exercise['id']) {
  //           existingExercises[i] = exercise;
  //           found = true;
  //           break;
  //         }
  //       }

  //       if (!found) {
  //         debugPrint("Exercise with id ${exercise['id']} is not found");
  //       } else {
  //         batch.update(docRef, {'exercises': existingExercises});
  //       }
  //     }
  //     await batch.commit();
  //   }
  // }

  Future<void> updateMoveExerciseInFirebase(
      DateTime date, List<Map<String, dynamic>> newExercises) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('exercises')
        .doc(dateString);

    final docSnapshot = await docRef.get();

    List<Map<String, dynamic>> exercises = [];
    if (docSnapshot.exists) {
      exercises =
          List<Map<String, dynamic>>.from(docSnapshot.data()!['exercises']);
    }

    // Merge new exercises with existing ones
    for (var newExercise in newExercises) {
      final index = exercises
          .indexWhere((exercise) => exercise['id'] == newExercise['id']);
      if (index != -1) {
        exercises[index] = newExercise; // Update existing exercise
      } else {
        exercises.add(newExercise); // Add new exercise
      }
    }

    await docRef.set({'exercises': exercises}, SetOptions(merge: true));
  }

  Future<void> removeExerciseFromFirebase(DateTime date, String uid) async {
    debugPrint("should be in removeExerciseFromFirebase menu");
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    final firestore = FirebaseFirestore.instance;

    // Reference to the document in the Firestore collection
    DocumentReference docRef = firestore
        .collection('Users')
        .doc(userUid)
        .collection('exercises')
        .doc(dateString);

    debugPrint("the doc ref is $docRef");

    try {
      // Get the document
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        List<dynamic> exercises = docSnapshot.get('exercises');

        exercises.removeWhere((exercise) => exercise['id'] == uid);

        await docRef.update({'exercises': exercises});
      }
    } catch (e) {
      debugPrint("Error removing exercise: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchExercises(DateTime date) async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    final firestore = FirebaseFirestore.instance;
    DocumentReference exerciseDetailsRef = firestore
        .collection('Users')
        .doc(userUid)
        .collection('exercises')
        .doc(dateString);

    try {
      DocumentSnapshot<Object?> querySnapshot = await exerciseDetailsRef.get();

      if (querySnapshot.exists) {
        var data = querySnapshot.data();
        debugPrint("whats that data! it's $data");
        if (data != null && data is Map<String, dynamic>) {
          debugPrint("these are the data you are looking for");
          List<Map<String, dynamic>> exerciseList =
              (data['exercises'] as List<dynamic>).map((entry) {
            return entry as Map<String, dynamic>;
          }).toList();

          return exerciseList;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load exercises: $e');
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
