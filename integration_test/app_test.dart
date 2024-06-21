// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/login_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/on_boarding.dart';
import 'package:fusion_workouts/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    "Inputting no user credentials shows and error "
    "and does not allow the user to go to their dashboard or onboarding page. ",
    (WidgetTester tester) async {
      // build and intialize the app
      await Firebase.initializeApp();
      await tester.pumpWidget(MyApp());

      // verify the splashscreen is displayed
      expect(find.text('Welcome to Fusion Workouts!'), findsOneWidget);

      await tester.pumpAndSettle(Duration(seconds: 3));

      expect(find.text('Login'), findsWidgets);

      await tester.enterText(find.byType(TextField).at(0), 'tucan.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');

      await tester.tap(find.byKey(Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(OnBoarding), findsNothing);
    },
  );

  // testWidgets("sign up test", (WidgetTester tester) async {
  //   // Build the app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());

  //   // wait for splash screen to navigate to login screen
  //   await tester.pump(const Duration(seconds: 3));

  //   // navigate to sing up screen
  //   final goToSignUp = find.byKey(const Key('signupButton'));
  //   await tester.tap(goToSignUp);
  //   await tester.pumpAndSettle();

  //   // Replace with the actual keys of your TextFormFields and signup button
  //   final emailField = find.byKey(const Key('emailField'));
  //   final passwordField = find.byKey(const Key('passwordField'));
  //   final usernameField = find.byKey(const Key('usernameField'));
  //   final signupButton = find.byKey(const Key('signupButton'));

  //   // Enter text into the fields
  //   await tester.enterText(emailField, 'test@example.com');
  //   await tester.enterText(passwordField, 'password123');
  //   await tester.enterText(usernameField, 'Test User');

  //   // Tap the signup button and trigger a frame
  //   await tester.tap(signupButton);
  //   await tester.pumpAndSettle();

  //   // Check that the OnBoarding page is displayed
  //   expect(find.byType(OnBoarding), findsOneWidget);
  // });
}
