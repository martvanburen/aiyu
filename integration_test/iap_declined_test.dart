import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

import "test_utils.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Tester should decline purchases for following tests:
  // ---------------------------------------------------------------------------
  group("end-to-end tests for in-app-purchases | declined purchase", () {
    testWidgets("guest, start purchase, cancel, try back-up account, log out",
        (tester) async {
      await initApp(tester, find);

      // Start top-up purchase.
      final Finder topUpButton = find.text("Add 50¢");
      await tester.tap(topUpButton);
      await tester.pump();

      // Check dialog opened.
      expect(find.text("Wallet Top-Up"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);

      // >>>
      // Tester Cancels In-App-Purchase
      // <<<

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
      await signOutTemporaryUser(tester, find);
    });

    testWidgets("log in, start purchase, cancel, log out", (tester) async {
      await initApp(tester, find);
      await logInAsTestUser(tester, find);
      await waitForWalletBalanceNonZero(tester, find);

      // Start top-up purchase.
      final Finder topUpButton = find.text("Add 50¢");
      await tester.tap(topUpButton);
      await tester.pump();

      // Check dialog opened.
      expect(find.text("Wallet Top-Up"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);

      // >>>
      // Tester Cancels In-App-Purchase
      // <<<

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

      // Sign out.
      await signOutTestUser(tester, find);
    });
  });
}
