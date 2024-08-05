// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/calorie_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/dashboard_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/login_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/on_boarding.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/signup_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/add_food_dialog.dart';
import 'package:fusion_workouts/firebase_options.dart';
import 'package:fusion_workouts/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.signOut();
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  Future<void> login(WidgetTester tester, email, password) async {
    final emailField = find.byKey(Key('emailField'));
    final passwordField = find.byKey(Key('passwordField'));
    final loginButton = find.byKey(Key('loginButton'));

    // Enter text into the fields
    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);

    // tap the login button
    await tester.tap(loginButton);

    await tester.pumpAndSettle(Duration(seconds: 1));
  }

  // test sign up functionality
  testWidgets("Test sign up functionality with credentials. ",
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.byType(LoginPage), findsOneWidget);

    final signupButton = find.byKey(Key('signupButton'));

    // tap the sign up button
    await tester.tap(signupButton);

    await tester.pumpAndSettle();
    // should be on the sign up page
    expect(find.byType(SignUpPage), findsOneWidget);

    final emailField = find.byKey(Key('emailField'));
    final passwordField = find.byKey(Key('passwordField'));
    final confirmPasswordField = find.byKey(Key('confirmPasswordField'));
    final signUp = find.byKey(Key('signupButton'));

    // Enter text into the fields
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'test123');
    await tester.enterText(confirmPasswordField, 'test123');

    await tester.tap(signUp);

    await tester.pumpAndSettle();

    expect(find.byType(OnBoarding), findsOneWidget);

    final nameField = find.byKey(Key('name'));
    final phoneNumberField = find.byKey(Key('phoneNumber'));
    final ageField = find.byKey(Key('age'));
    final sexField = find.byKey(Key('sex'));
    final weightField = find.byKey(Key('weight'));
    final heightField = find.byKey(Key('height'));
    final availabilityField = find.byKey(Key('availability'));
    final onboardButton = find.byKey(Key('onboardButton'));

    await tester.enterText(nameField, 'test user');
    await tester.enterText(phoneNumberField, '1234567890');
    await tester.enterText(ageField, '20');
    await tester.enterText(sexField, 'Male');
    await tester.enterText(weightField, '185');
    await tester.enterText(heightField, '6\'');
    await tester.enterText(availabilityField, '5');

    await tester.ensureVisible(onboardButton);
    await tester.pumpAndSettle(Duration(seconds: 1));

    await tester.tap(onboardButton);
    await tester.pumpAndSettle();

    expect(find.byType(DashboardPage), findsOneWidget);

    // final logoutButton = find.byKey(Key('logoutButton'));

    // await tester.tap(logoutButton);

    // await tester.pumpAndSettle();

    // expect(find.byType(LoginPage), findsOneWidget);
  });

//   // check that the correct information has been uploaded to Firestore
//   testWidgets("Test that Firestore has the correct data",
//       (WidgetTester tester) async {
//     await tester.pumpWidget(const MyApp());

//     expect(find.byType(LoginPage), findsOneWidget);

//     await login(tester, 'test@example.com', 'test123');

//     expect(find.byType(DashboardPage), findsOneWidget);

//     final firestoreInstance = FirebaseFirestore.instance;
//     final userUid = FirebaseAuth.instance.currentUser!.uid;
//     final docSnapshot = await firestoreInstance
//         .collection('Users')
//         .doc(userUid)
//         .collection('userProfile')
//         .doc('profileInformation')
//         .get();

//     expect(docSnapshot.exists, true);
//     expect(docSnapshot.data()?['name'], 'test user');
//     expect(docSnapshot.data()?['phoneNumber'], '1234567890');
//     expect(docSnapshot.data()?['age'], '20');
//     expect(docSnapshot.data()?['sex'], 'Male');
//     expect(docSnapshot.data()?['weight'], '185');
//     expect(docSnapshot.data()?['height'], '6\'');
//     expect(docSnapshot.data()?['availability'], '5');

//     final logoutButton = find.byKey(Key('logoutButton'));

//     await tester.tap(logoutButton);

//     await tester.pumpAndSettle();

//     expect(find.byType(LoginPage), findsOneWidget);
//   });

//   // test wrong password credentials
//   testWidgets(
//       "Test login functionality where user enters correct credentials. ",
//       (WidgetTester tester) async {
//     // Build the app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     expect(find.byType(LoginPage), findsOneWidget);

//     await login(tester, 'test@example.com', 'test123aa');

//     // verify the user is on the login page with an alert message
//     expect(find.byType(LoginPage), findsOneWidget);
//   });

//   // test login no user credentials
//   testWidgets(
//       "Test login functionality where the user enters credentials not within Auth. ",
//       (WidgetTester tester) async {
//     // Build the app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     expect(find.byType(LoginPage), findsOneWidget);

//     await login(tester, 'test@gmail.com', 'test123');

//     // verify the user is on the login page with an alert message
//     expect(find.byType(LoginPage), findsOneWidget);
//   });

//   // test correct credentials
//   testWidgets(
//       "Test login functionality where user enters correct credentials. ",
//       (WidgetTester tester) async {
//     // Build the app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     expect(find.byType(LoginPage), findsOneWidget);

//     await login(tester, 'test@example.com', 'test123');

//     // verify the user is on the login page with an alert message
//     expect(find.byType(DashboardPage), findsOneWidget);

//     final logoutButton = find.byKey(Key('logoutButton'));

//     await tester.tap(logoutButton);

//     await tester.pumpAndSettle();

//     expect(find.byType(LoginPage), findsOneWidget);
//   });

//   // test drawer functionality
//   testWidgets("Test drawer functionality. ", (WidgetTester tester) async {
//     await tester.pumpWidget(const MyApp());

//     expect(find.byType(LoginPage), findsOneWidget);

//     await login(tester, 'test@example.com', 'test123');

//     // should find the dashboard page
//     expect(find.byType(DashboardPage), findsOneWidget);

//     await tester.tap(find.byIcon(Icons.menu));

//     await tester.pumpAndSettle();

//     final workouts = find.text('Workouts');

//     expect(workouts, findsOneWidget);

//     final Size screenSize = tester.getSize(find.byType(MaterialApp));

//     final Offset tapPoint =
//         Offset(screenSize.width - 10, screenSize.height / 2);

//     await tester.tapAt(tapPoint);
//     await tester.pumpAndSettle();

//     final logoutButton = find.byKey(Key('logoutButton'));

//     await tester.tap(logoutButton);

//     await tester.pumpAndSettle();

//     expect(find.byType(LoginPage), findsOneWidget);
//   });

//   // test adding an event and workout functionality
//   testWidgets("Test adding Chest event and workouts",
//       (WidgetTester tester) async {
//     await tester.pumpWidget(const MyApp());

//     // FirebaseAuth.instance.signOut();
//     // tester.pumpAndSettle();

//     expect(find.byType(LoginPage), findsOneWidget);

//     await login(tester, 'test@example.com', 'test123');
//     // should find the dashboard page
//     expect(find.byType(DashboardPage), findsOneWidget);

//     await tester.tap(find.byIcon(Icons.menu));
//     await tester.pumpAndSettle();

//     final workouts = find.text('Workouts');

//     expect(workouts, findsOneWidget);

//     final workoutsButton = find.byKey(Key('workoutsButton'));

//     await tester.tap(workoutsButton);
//     await tester.pumpAndSettle();

//     expect(find.byType(WorkoutsPage), findsOneWidget);

//     final addEventFloatingActionButton =
//         find.byKey(Key('addEventFloatingActionButton'));

//     await tester.tap(addEventFloatingActionButton);
//     await tester.pumpAndSettle();

//     final eventNameField = find.byKey(Key('eventNameField'));

//     await tester.enterText(eventNameField, 'Chest');

//     final addEventButton = find.byKey(Key('addEventButton'));

//     await tester.tap(addEventButton);
//     await tester.pumpAndSettle();

//     expect(find.text('Chest'), findsOneWidget);

//     final eventAddIcon = find.byKey(Key('eventAddIcon'));

//     await tester.tap(eventAddIcon);
//     await tester.pumpAndSettle();

//     await tester.enterText(find.byKey(Key('exerciseNameField')), 'Bench');
//     await tester.enterText(find.byKey(Key('weightField')), '185');
//     await tester.enterText(find.byKey(Key('repsField')), '6');
//     await tester.enterText(find.byKey(Key('setsField')), '3');
//     await tester.pump();

//     await tester.tap(find.byKey(Key('addWorkoutButton')));
//     await tester.pumpAndSettle();

//     expect(find.text('Bench (185 lbs, 6 reps, 3 sets)'), findsOneWidget);

//     for (var i = 2; i <= 5; i++) {
//       await tester.tap(find.byKey(Key('eventAddIcon')));
//       await tester.pumpAndSettle();

//       await tester.enterText(
//           find.byKey(Key('exerciseNameField')), 'Exercise $i');
//       await tester.enterText(find.byKey(Key('weightField')), '$i');
//       await tester.enterText(find.byKey(Key('repsField')), '${i * 2}');
//       await tester.enterText(find.byKey(Key('setsField')), '${i + 1}');
//       await tester.pump();

//       await tester.tap(find.byKey(Key('addWorkoutButton')));
//       await tester.pumpAndSettle();

//       expect(find.text('Exercise $i ($i lbs, ${i * 2} reps, ${i + 1} sets)'),
//           findsOneWidget);
//     }

//     expect(find.byType(ListTile), findsNWidgets(5));
//   });

//   testWidgets("Test adding Legs event and workouts",
//       (WidgetTester tester) async {
//     await tester.pumpWidget(const MyApp());

//     // FirebaseAuth.instance.signOut();
//     // tester.pumpAndSettle();

//     expect(find.byType(LoginPage), findsOneWidget);

//     await login(tester, 'test@example.com', 'test123');
//     // should find the dashboard page
//     expect(find.byType(DashboardPage), findsOneWidget);

//     await tester.tap(find.byIcon(Icons.menu));
//     await tester.pumpAndSettle();

//     final workouts = find.text('Workouts');

//     expect(workouts, findsOneWidget);

//     final workoutsButton = find.byKey(Key('workoutsButton'));

//     await tester.tap(workoutsButton);
//     await tester.pumpAndSettle();

//     expect(find.byType(WorkoutsPage), findsOneWidget);

//     final addEventFloatingActionButton =
//         find.byKey(Key('addEventFloatingActionButton'));

//     await tester.tap(addEventFloatingActionButton);
//     await tester.pumpAndSettle();

//     final eventNameField = find.byKey(Key('eventNameField'));

//     await tester.enterText(eventNameField, 'Chest');

//     final addEventButton = find.byKey(Key('addEventButton'));

//     await tester.tap(addEventButton);
//     await tester.pumpAndSettle();

//     expect(find.text('Chest'), findsOneWidget);

//     final eventAddIcon = find.byKey(Key('eventAddIcon'));

//     await tester.tap(eventAddIcon);
//     await tester.pumpAndSettle();

//     await tester.enterText(find.byKey(Key('exerciseNameField')), 'Bench');
//     await tester.enterText(find.byKey(Key('weightField')), '185');
//     await tester.enterText(find.byKey(Key('repsField')), '6');
//     await tester.enterText(find.byKey(Key('setsField')), '3');
//     await tester.pump();

//     await tester.tap(find.byKey(Key('addWorkoutButton')));
//     await tester.pumpAndSettle();

//     expect(find.text('Bench (185 lbs, 6 reps, 3 sets)'), findsOneWidget);

//     for (var i = 2; i <= 5; i++) {
//       await tester.tap(find.byKey(Key('eventAddIcon')));
//       await tester.pumpAndSettle();

//       await tester.enterText(
//           find.byKey(Key('exerciseNameField')), 'Exercise $i');
//       await tester.enterText(find.byKey(Key('weightField')), '$i');
//       await tester.enterText(find.byKey(Key('repsField')), '${i * 2}');
//       await tester.enterText(find.byKey(Key('setsField')), '${i + 1}');
//       await tester.pump();

//       await tester.tap(find.byKey(Key('addWorkoutButton')));
//       await tester.pumpAndSettle();

//       expect(find.text('Exercise $i ($i lbs, ${i * 2} reps, ${i + 1} sets)'),
//           findsOneWidget);
//     }

//     expect(find.byType(ListTile), findsNWidgets(5));
//   });

//   // test login in and ensuring that workouts are read into calendar.
//   testWidgets(
//       "Test whether workouts in firestore properly populate in calendar",
//       (WidgetTester tester) async {
//     await tester.pumpWidget(const MyApp());

//     expect(find.byType(LoginPage), findsOneWidget);

//     await login(tester, 'test@example.com', 'test123');
//     // should find the dashboard page
//     expect(find.byType(DashboardPage), findsOneWidget);

//     await tester.tap(find.byIcon(Icons.menu));
//     await tester.pumpAndSettle();

//     final workouts = find.text('Workouts');

//     expect(workouts, findsOneWidget);

//     final workoutsButton = find.byKey(Key('workoutsButton'));

//     await tester.tap(workoutsButton);
//     await tester.pumpAndSettle();

//     expect(find.byType(WorkoutsPage), findsOneWidget);

//     expect(find.text('Chest'), findsOneWidget);

//     expect(find.byType(ListTile), findsNWidgets(5));
//   });

//   testWidgets("Test calorie page functionality", (WidgetTester tester) async {
//     await tester.pumpWidget(const MyApp());

//     expect(find.byType(LoginPage), findsOneWidget);

//     await login(tester, 'test@example.com', 'test123');
//     // should find the dashboard page
//     expect(find.byType(DashboardPage), findsOneWidget);

//     await tester.tap(find.byIcon(Icons.menu));
//     await tester.pumpAndSettle();

//     final calories = find.text("Calorie Tracking");

//     expect(calories, findsOneWidget);

//     final calorieButton = find.byKey(Key('calorieButton'));

//     await tester.tap(calorieButton);
//     await tester.pumpAndSettle();

//     expect(find.byType(CalorieTrackingPage), findsOneWidget);

//     final breakfastWidget = find.byKey(Key('breakfast mealsummarywidget'));

//     await tester.tap(breakfastWidget);
//     await tester.pumpAndSettle();

//     final searchController = find.byKey(Key('searchController'));

//     await tester.tap(searchController);
//     await tester.pumpAndSettle();

//     await tester.enterText(searchController, 'Hard Boiled Eggs');
//     await tester.pump();

//     final searchButton = find.byIcon(Icons.search);

//     await tester.tap(searchButton);
//     await tester.pumpAndSettle();

//     final thirdTileFinder = find.byType(ListTile).at(2);

//     await tester.tap(thirdTileFinder);
//     await tester.pumpAndSettle();

//     expect(find.text('Add Food'), findsOneWidget);

//     final dropdownFinder = find.byKey(Key('DropdownMenu'));

//     await tester.tap(dropdownFinder);
//     await tester.pumpAndSettle();

//     final menuItemFinder = find.text('6').last;
//     await tester.tap(menuItemFinder);
//     await tester.pumpAndSettle();

//     final addFoodButton = find.byKey(Key('AddFoodButton'));
//     await tester.tap(addFoodButton);
//     await tester.pumpAndSettle();

//     expect(find.byType(AddFoodDialog), findsOneWidget);

//     final modalBarrierFinder = find.byType(ModalBarrier).last;

//     await tester.tap(modalBarrierFinder);
//     await tester.pumpAndSettle();

//     expect(find.byType(CalorieTrackingPage), findsOneWidget);
//   });
// }
}
