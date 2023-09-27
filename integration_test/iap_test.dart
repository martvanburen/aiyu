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

  // Tester should accept purchases for following tests:
  // ---------------------------------------------------------------------------
  group("end-to-end tests for in-app-purchases | successful purchase", () {
    testWidgets("guest, start purchase, approved, try back-up account, log out",
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
      // Tester Completes In-App-Purchase
      // <<<

      // After purchase completed, dialog should be closable.
      await tester.pumpAndSettle();
      expect(find.text("Close"), findsOneWidget);

      // Close dialog, should not ask confirmation message.
      final Finder closeButton = find.text("Close");
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
      expect(find.text("Wallet Top-Up"), findsNothing);
      expect(find.text("Confirmation"), findsNothing);

      // App should confirm if user wants to back up their account.
      expect(find.text("Back-Up Your Account"), findsOneWidget);
      expect(find.text("Yes"), findsOneWidget);
      expect(find.text("No"), findsOneWidget);

      // Say yes to add email to account.
      final Finder yesButton = find.text("Yes");
      await tester.tap(yesButton);
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

      // Cancel back-up account dialog.
      final Finder cancelButton = find.text("Cancel");
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Balance should be updated to 50c.
      expect(find.text("Wallet Balance:"), findsOneWidget);
      expect(find.text("50.0¢"), findsOneWidget);

      // Sign out.
      await signOutTemporaryUser(tester, find);
    });

    testWidgets("log in, start purchase, approved, log out", (tester) async {
      await initApp(tester, find);
      await logInAsTestUser(tester, find);
      await waitForWalletBalanceNonZero(tester, find);

      // Find wallet balance.
      final Finder balanceFinder = find.byKey(const ValueKey('balanceText'));
      var balanceTextWidget = balanceFinder.evaluate().single.widget as Text;
      var balanceText = balanceTextWidget.data!;
      var balance =
          double.parse(balanceText.substring(0, balanceText.length - 1));

      // Start top-up purchase.
      final Finder topUpButton = find.text("Add 50¢");
      await tester.tap(topUpButton);
      await tester.pump();

      // Check dialog opened.
      expect(find.text("Wallet Top-Up"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);

      // >>>
      // Tester Completes In-App-Purchase
      // <<<

      // After purchase completed, dialog should be closable.
      await tester.pumpAndSettle();
      expect(find.text("Close"), findsOneWidget);

      // Close dialog, should not ask confirmation or backing up account.
      final Finder closeButton = find.text("Close");
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
      expect(find.text("Wallet Top-Up"), findsNothing);
      expect(find.text("Confirmation"), findsNothing);
      expect(find.text("Back-Up Your Account"), findsNothing);
      expect(find.text("Wallet Balance:"), findsOneWidget);

      // Balance should be 50c higher.
      balanceTextWidget = balanceFinder.evaluate().single.widget as Text;
      balanceText = balanceTextWidget.data!;
      expect(
        double.parse(balanceText.substring(0, balanceText.length - 1)),
        equals(balance + 50.0),
      );

      // Sign out.
      await signOutTestUser(tester, find);
    });
  });
}
