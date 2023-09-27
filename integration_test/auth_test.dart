import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

import "test_utils.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("end-to-end tests for login & wallet functionality", () {
    testWidgets("basic wallet info", (tester) async {
      await initApp(tester, find);

      final Finder infoButton = find.byIcon(Icons.info);
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      expect(find.text("Wallet Information"), findsOneWidget);
      expect(find.text("Restore Account"), findsOneWidget);
      expect(find.text("Close"), findsOneWidget);

      final Finder closeButton = find.text("Close");
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.text("Wallet Information"), findsNothing);
    });

    testWidgets("restore real account (initiate only)", (tester) async {
      await initApp(tester, find);

      // Open wallet info.
      final Finder infoButton = find.byIcon(Icons.info);
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      // Tap restore account.
      final Finder restoreButton = find.text("Restore Account");
      await tester.tap(restoreButton);
      await tester.pumpAndSettle();

      // Verify that the restore account dialog is open.
      expect(find.text("Restore Account"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Next"), findsOneWidget);

      // Enter email and submit.
      final Finder emailField = find.ancestor(
        of: find.text("Email"),
        matching: find.byType(TextField),
      );
      await tester.enterText(emailField, "success@simulator.amazonses.com");
      final Finder nextButton = find.text("Next");
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Ensure verification code page is shown.
      expect(find.text("Verification Code"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Complete"), findsOneWidget);

      // Enter (wrong) verification code and submit.
      final Finder verificationCodeField = find.ancestor(
        of: find.text("Verification Code"),
        matching: find.byType(TextField),
      );
      await tester.enterText(verificationCodeField, "123456");
      final Finder completeButton = find.text("Complete");
      await tester.tap(completeButton);
      await tester.pumpAndSettle();

      // Expect error message shown.
      expect(find.text("Invalid verification code provided, please try again."),
          findsOneWidget);
    });

    testWidgets("restore test account (and sign out)", (tester) async {
      await initApp(tester, find);

      // Open wallet info and initiate restore.
      final Finder infoButton = find.byIcon(Icons.info);
      await tester.tap(infoButton);
      await tester.pumpAndSettle();
      final Finder restoreButton = find.text("Restore Account");
      await tester.tap(restoreButton);
      await tester.pumpAndSettle();

      // Enter test email.
      final Finder emailField = find.ancestor(
        of: find.text("Email"),
        matching: find.byType(TextField),
      );
      await tester.enterText(emailField, "test_user");
      final Finder nextButton = find.text("Next");
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Enter test password.
      final Finder verificationCodeField = find.ancestor(
        of: find.text("Verification Code"),
        matching: find.byType(TextField),
      );
      await tester.enterText(
          verificationCodeField, "012345678901234567890123456789");
      final Finder completeButton = find.text("Complete");
      await tester.tap(completeButton);
      await tester.pumpAndSettle();

      // Check snackbar message.
      expect(find.text("Account restored!"), findsOneWidget);

      // Wait until balance is updated.
      await waitForWalletBalanceNonZero(tester, find);

      // Check dialog dismissed and wallet info updated.
      expect(find.text("Restore Account"), findsNothing);
      expect(find.text("Wallet Balance:"), findsOneWidget);
      expect(find.text("0.0¢"), findsNothing);

      // Sign out.
      await signOutBackedUpUser(tester, find);

      // Check wallet info updated.
      expect(find.text("Wallet Information"), findsNothing);
      expect(find.text("Wallet Balance:"), findsOneWidget);
      expect(find.text("0.0¢"), findsOneWidget);
    });
  });
}
