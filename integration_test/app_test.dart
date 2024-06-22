// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/dashboard_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/login_page.dart';
import 'package:fusion_workouts/firebase_options.dart';
import 'package:fusion_workouts/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  });

  // test login no user credentials
  testWidgets(
      "Test login functionality where the user enters credentials not within Auth. ",
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.byType(LoginPage), findsOneWidget);

    final emailField = find.byKey(Key('emailField'));
    final passwordField = find.byKey(Key('passwordField'));
    final loginButton = find.byKey(Key('loginButton'));

    // Enter text into the fields
    await tester.enterText(emailField, 'test@gmail.com');
    await tester.enterText(passwordField, 'test123');

    // tap the login button
    await tester.tap(loginButton);

    // wait for the alert message to show.
    await tester.pumpAndSettle();

    // verify the user is on the login page with an alert message
    expect(find.byType(LoginPage), findsOneWidget);
  });

  // test correct credentials
  testWidgets(
      "Test login functionality where user enters correct credentials. ",
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.byType(LoginPage), findsOneWidget);

    final emailField = find.byKey(Key('emailField'));
    final passwordField = find.byKey(Key('passwordField'));
    final loginButton = find.byKey(Key('loginButton'));

    // Enter text into the fields
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'test123');

    // tap the login button
    await tester.tap(loginButton);

    // wait for the alert message to show.
    await tester.pumpAndSettle(Duration(seconds: 1));

    // verify the user is on the login page with an alert message
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  // test wrong email credentials
  testWidgets(
      "Test login functionality where user enters correct credentials. ",
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.byType(LoginPage), findsOneWidget);

    final emailField = find.byKey(Key('emailField'));
    final passwordField = find.byKey(Key('passwordField'));
    final loginButton = find.byKey(Key('loginButton'));

    // Enter text into the fields
    await tester.enterText(emailField, 'test@example.comm');
    await tester.enterText(passwordField, 'test123');

    // tap the login button
    await tester.tap(loginButton);

    // wait for the alert message to show.
    await tester.pumpAndSettle(Duration(seconds: 1));

    // verify the user is on the login page with an alert message
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
