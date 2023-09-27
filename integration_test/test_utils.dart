import "package:ai_yu/data/state_models/aws_model.dart";
import "package:ai_yu/main.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

Future<GlobalKey<AiYuAppState>> initApp(
    WidgetTester tester, CommonFinders find) async {
  GlobalKey<AiYuAppState> appKey = GlobalKey<AiYuAppState>();
  WidgetController.hitTestWarningShouldBeFatal = true;
  try {
    await tester.pumpWidget(await buildApp(key: appKey));
  } on Exception catch (e) {
    safePrint("Note: Failed to initialize Amplify. $e.");
  }
  await tester.pumpAndSettle();
  expect(find.text("0.0¢"), findsOneWidget);
  expect(find.text("Add 50¢"), findsOneWidget);
  return appKey;
}

Future<void> logInAsTestUser(WidgetTester tester, CommonFinders find) async {
  // Open wallet info dialog.
  final Finder infoButton = find.byIcon(Icons.info);
  await tester.tap(infoButton);
  await tester.pumpAndSettle();

  // Initiate restore-account.
  final Finder restoreButton = find.text("Restore Account");
  await tester.tap(restoreButton);
  await tester.pumpAndSettle();

  // Enter test credentials email.
  final Finder emailField = find.ancestor(
    of: find.text("Email"),
    matching: find.byType(TextField),
  );
  await tester.enterText(emailField, "test_user");
  final Finder nextButton = find.text("Next");
  await tester.tap(nextButton);
  await tester.pumpAndSettle();

  // Enter test credentials password.
  final Finder verificationCodeField = find.ancestor(
    of: find.text("Verification Code"),
    matching: find.byType(TextField),
  );
  await tester.enterText(
      verificationCodeField, "012345678901234567890123456789");
  final Finder completeButton = find.text("Complete");
  await tester.tap(completeButton);
  await tester.pumpAndSettle();
}

Future<void> waitForWalletBalanceNonZero(
    WidgetTester tester, CommonFinders find) async {
  int i = 0;
  while (find.text("0.0¢").evaluate().isNotEmpty) {
    if (i++ > 5) {
      fail("Wallet balance fetch did not get triggered on sign-in.");
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
}

// For backed-up accounts such as the test account, sign out using sign-out
// button.
Future<void> signOutTestUser(WidgetTester tester, CommonFinders find) async {
  // Open wallet info and check user is signed in.
  final Finder infoButton = find.byIcon(Icons.info);
  await tester.tap(infoButton);
  await tester.pumpAndSettle();
  expect(find.text("Sign Out"), findsOneWidget);

  // Press sign-out button and wait for completion.
  final Finder signOutButton = find.text("Sign Out");
  await tester.tap(signOutButton);
  await tester.pumpAndSettle();
  int i = 0;
  while (find.text("Sign Out").evaluate().isNotEmpty) {
    if (i++ > 10) {
      fail("Sign out took too long.");
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
  expect(find.text("Restore Account"), findsOneWidget);

  // Close wallet info dialog.
  final Finder closeButton = find.text("Close");
  await tester.tap(closeButton);
  await tester.pumpAndSettle();
}

// For temporary users no sign-out button exists, so directly call Amplify.
Future<void> signOutTemporaryUser(
    WidgetTester tester, CommonFinders find) async {
  AWSModel.signOut();
}
