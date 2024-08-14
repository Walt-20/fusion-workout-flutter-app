// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/entry.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/event.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/exercise.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food_database.dart';
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
      debugPrint("Profile information added successfuly");
    }).catchError((onError) {
      debugPrint(onError.toString());
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('exercises')
        .doc('initial')
        .set({
      'initialized': true,
    }).then((value) {
      debugPrint("Exercises collection initialized successfully");
    }).catchError((onError) {
      debugPrint(
          "Error initializing exercises collection: ${onError.toString()}");
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meals')
        .doc('initial')
        .set({
      'initialized': true,
    }).then((value) {
      debugPrint("Meals collection initialized successfully");
    }).catchError((onError) {
      debugPrint("Error initializing meals collection: ${onError.toString()}");
    });
  }

  Future<void> addExerciseToFirestore(
      DateTime date, List<Map<String, dynamic>> exercises) async {
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

    if (docSnapshot.exists) {
      List<dynamic> existingExercises = docSnapshot.data()?['exercises'] ?? [];

      bool found = false;
      for (var i = 0; i < existingExercises.length; i++) {
        if (existingExercises[i]['id'] == exercise['id']) {
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
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    final firestore = FirebaseFirestore.instance;

    // Reference to the document in the Firestore collection
    DocumentReference docRef = firestore
        .collection('Users')
        .doc(userUid)
        .collection('exercises')
        .doc(dateString);

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
        if (data != null && data is Map<String, dynamic>) {
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

  // user can add food
  Future<void> addFoodToDatabase(
      Map<String, List<FoodForDatabase>> food, DateTime date) async {
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    final userMealsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meals')
        .doc(dateString);

    try {
      final existingDataSnapshot = await userMealsCollection.get();
      Map<String, dynamic> existingData = existingDataSnapshot.data() ?? {};

      Map<String, dynamic> foodData = {};

      debugPrint("food is ${food.toString()}");

      food.forEach((mealType, foodList) {
        // Initialize meal type if it doesn't exist
        List<Map<String, dynamic>> existingFoodList =
            existingData[mealType]?.cast<Map<String, dynamic>>() ?? [];
        List<Map<String, dynamic>> newFoodList = foodList.map((foodItem) {
          final foodItemMap = foodItem.toMap();
          return foodItemMap;
        }).toList();

        // Merge existing and new food items
        newFoodList.forEach((newFoodItem) {
          int index = existingFoodList.indexWhere((existingFoodItem) =>
              existingFoodItem['foodId'] == newFoodItem['foodId']);
          if (index != -1) {
            // Update existing food item
            existingFoodList[index] = newFoodItem;
          } else {
            // Add new food item
            existingFoodList.add(newFoodItem);
          }
        });

        foodData[mealType] = existingFoodList;
      });

      debugPrint("What is foodData? ${foodData.toString()}");

      // Set the new structure in Firestore if it doesn't exist
      await userMealsCollection.set(foodData, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error adding food to database: $e");
    }
  }

  Future<void> removeFoodFromDatabase(
      String mealType, String foodId, DateTime date) async {
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    final userMealsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meals')
        .doc(dateString);

    try {
      final existingDataSnapshot = await userMealsCollection.get();
      Map<String, dynamic> existingData = existingDataSnapshot.data() ?? {};

      if (existingData.containsKey(mealType)) {
        List<Map<String, dynamic>> foodList =
            existingData[mealType]?.cast<Map<String, dynamic>>() ?? [];

        // Remove the food item with the specified foodId
        foodList.removeWhere((foodItem) => foodItem['foodId'] == foodId);

        // Update the Firestore document
        existingData[mealType] = foodList;
        await userMealsCollection.set(existingData, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Error removing food from database: $e");
    }
  }

  Future<Map<String, List<Food>>> fetchFoodFromFirestore(DateTime date) async {
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    final userMealsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meals')
        .doc(dateString);

    Map<String, List<Food>> retFoods = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
      'Snacks': [],
    };
    try {
      DocumentSnapshot mealDocSnapshot = await userMealsCollection.get();

      if (mealDocSnapshot.exists) {
        Map<String, dynamic> data =
            mealDocSnapshot.data() as Map<String, dynamic>;

        final futures = <Future<void>>[];
        data.forEach((mealType, foodList) {
          for (var food in foodList) {
            final foodId = food['foodId'];
            debugPrint("whats that id? $foodId");
            futures.add(
              fetchFoods(foodId).then((foodDetails) {
                final food = Food.fromJson(foodDetails);
                if (retFoods.containsKey(mealType)) {
                  retFoods[mealType]!.add(food);
                }
              }).catchError((error) {
                debugPrint("Error fetching food details: $error");
              }),
            );
          }
        });

        await Future.wait(futures);
      } else {
        debugPrint("Document does not exists");
      }
    } catch (e) {
      debugPrint("error $e");
    }
    return retFoods;
  }

  Future<Map<String, dynamic>> fetchFoods(String foodId) async {
    final url = Uri.parse('http://10.0.2.2:3000/fetch-food-id');

    try {
      final response = await http.get(
        Uri.parse('$url?searchExpression=$foodId'),
      );

      debugPrint("whats that response? $response");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        debugPrint("the decoded json is ${responseBody}");

        if (responseBody.containsKey('food')) {
          return responseBody['food'] as Map<String, dynamic>;
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        debugPrint("Error fetching food details: ${response.statusCode}");
        throw Exception('Failed to load foods');
      }
    } catch (e) {
      throw Exception('OAuth Token has expired. Signout and log back in. $e');
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
        debugPrint("the json data is $jsonData");
      }
    } catch (e) {}
  }
}
