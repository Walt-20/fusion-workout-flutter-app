// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/dashboard_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/login_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/signup_page.dart';
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

    expect(find.byType(DashboardPage), findsOneWidget);

    final logoutButton = find.byKey(Key('logoutButton'));

    await tester.tap(logoutButton);

    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  // test wrong password credentials
  testWidgets(
      "Test login functionality where user enters correct credentials. ",
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.byType(LoginPage), findsOneWidget);

    await login(tester, 'test@example.com', 'test123aa');

    // verify the user is on the login page with an alert message
    expect(find.byType(LoginPage), findsOneWidget);
  });

  // test login no user credentials
  testWidgets(
      "Test login functionality where the user enters credentials not within Auth. ",
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.byType(LoginPage), findsOneWidget);

    await login(tester, 'test@gmail.com', 'test123');

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

    await login(tester, 'test@example.com', 'test123');

    // verify the user is on the login page with an alert message
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  // test drawer functionality
  testWidgets("Test drawer functionality. ", (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(LoginPage), findsOneWidget);

    await login(tester, 'test@example.com', 'test123');

    // should find the dashboard page
    expect(find.byType(DashboardPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));

    await tester.pumpAndSettle();

    final workouts = find.text('Workouts');

    expect(workouts, findsOneWidget);
  });
}
