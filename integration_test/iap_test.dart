import "package:ai_yu/data/state_models/aws_model.dart";
import "package:ai_yu/main.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Tester should decline purchases for following tests:
  // ---------------------------------------------------------------------------
  group("end-to-end tests for in-app-purchases | declined purchase", () {
    testWidgets(
        "not logged in, start purchase, cancel, and try backing up account",
        (tester) async {
      await tester.pumpWidget(await buildApp());
      await tester.pumpAndSettle();

      expect(find.text("0.0¢"), findsOneWidget);
      expect(find.text("Add 50¢"), findsOneWidget);

      // Start top-up purchase.
      final Finder topUpButton = find.text("Add 50¢");
      await tester.tap(topUpButton);
      await tester.pump();

      // Check dialog opened.
      expect(find.text("Wallet Top-Up"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);

      // After purchase failed, dialog should be closable.
      await tester.pumpAndSettle();
      expect(find.text("Close"), findsOneWidget);

      // Close dialog, should not ask confirmation message.
      final Finder closeButton = find.text("Close");
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
      expect(find.text("Wallet Top-Up"), findsNothing);
      expect(find.text("Confirmation"), findsNothing);

      // Balance should not have changed.
      expect(find.text("Wallet Balance:"), findsOneWidget);
      expect(find.text("0.0¢"), findsOneWidget);

      // Open wallet info and check user is signed into temporary account.
      final Finder infoButton = find.byIcon(Icons.info);
      await tester.tap(infoButton);
      await tester.pumpAndSettle();
      expect(find.text("Backup Account"), findsOneWidget);

      // Try adding already in-use email to account.
      final Finder backupButton = find.text("Backup Account");
      await tester.tap(backupButton);
      await tester.pumpAndSettle();
      final Finder emailField = find.ancestor(
        of: find.text("Email"),
        matching: find.byType(TextField),
      );
      await tester.enterText(emailField, "success@simulator.amazonses.com");
      final Finder nextButton = find.text("Next");
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      expect(find.text("Email is already registered to another account."),
          findsOneWidget);

      // Try adding new email to account.
      await tester.enterText(
          emailField, "success+unusedemail@simulator.amazonses.com");
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      expect(find.text("Verification Code"), findsOneWidget);
      final Finder verificationCodeField = find.ancestor(
        of: find.text("Verification Code"),
        matching: find.byType(TextField),
      );
      await tester.enterText(verificationCodeField, "123456");
      final Finder completeButton = find.text("Complete");
      await tester.tap(completeButton);
      await tester.pumpAndSettle();
      expect(find.text("Invalid verification code provided, please try again."),
          findsOneWidget);

      // Sign out.
      AWSModel.signOut();
    });

    testWidgets("logged in, start purchase, cancel", (tester) async {
      await tester.pumpWidget(await buildApp());
      await tester.pumpAndSettle();

      expect(find.text("0.0¢"), findsOneWidget);
      expect(find.text("Add 50¢"), findsOneWidget);

      // Sign in to test account.
      final Finder infoButton = find.byIcon(Icons.info);
      await tester.tap(infoButton);
      await tester.pumpAndSettle();
      final Finder restoreButton = find.text("Restore Account");
      await tester.tap(restoreButton);
      await tester.pumpAndSettle();
      final Finder emailField = find.ancestor(
        of: find.text("Email"),
        matching: find.byType(TextField),
      );
      await tester.enterText(emailField, "test_user");
      final Finder nextButton = find.text("Next");
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      final Finder verificationCodeField = find.ancestor(
        of: find.text("Verification Code"),
        matching: find.byType(TextField),
      );
      await tester.enterText(
          verificationCodeField, "012345678901234567890123456789");
      final Finder completeButton = find.text("Complete");
      await tester.tap(completeButton);
      await tester.pumpAndSettle();

      // Start top-up purchase.
      final Finder topUpButton = find.text("Add 50¢");
      await tester.tap(topUpButton);
      await tester.pump();

      // Check dialog opened.
      expect(find.text("Wallet Top-Up"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);

      // After purchase failed, dialog should be closable.
      await tester.pumpAndSettle();
      expect(find.text("Close"), findsOneWidget);

      // Close dialog, should not ask confirmation message.
      final Finder closeButton = find.text("Close");
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
      expect(find.text("Wallet Top-Up"), findsNothing);
      expect(find.text("Confirmation"), findsNothing);
      expect(find.text("Wallet Balance:"), findsOneWidget);

      // Open wallet info and check user is signed in.
      await tester.tap(infoButton);
      await tester.pumpAndSettle();
      expect(find.text("Sign Out"), findsOneWidget);

      // Sign out and wait until complete.
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
    });
  });

  // Tester should accept purchases for following tests:
  // ---------------------------------------------------------------------------
  group("end-to-end tests for in-app-purchases | successful purchase", () {});
}
