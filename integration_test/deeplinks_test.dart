import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

import "test_utils.dart";

const String _testDeeplinkName = "Automated Test Item";
const String _testDeeplinkUrl = "automated-test";

Future<void> _createBasicDeeplink(
    WidgetTester tester, CommonFinders find) async {
  // Open new deeplink page.
  final Finder configureButton = find.text("Configure Deeplinks");
  await tester.tap(configureButton);
  await tester.pumpAndSettle();
  final Finder addDeeplinkButton = find.text("+ Add New Deeplink");
  await tester.tap(addDeeplinkButton);
  await tester.pumpAndSettle();

  // Enter data and save.
  final Finder nameField = find.ancestor(
    of: find.text("Name"),
    matching: find.byType(TextField),
  );
  final Finder deeplinkUrlField = find.ancestor(
    of: find.text("Deeplink URL"),
    matching: find.byType(TextField),
  );
  final Finder gptPromptField = find.ancestor(
    of: find.text("GPT Prompt"),
    matching: find.byType(TextField),
  );
  await tester.enterText(nameField, _testDeeplinkName);
  await tester.enterText(deeplinkUrlField, _testDeeplinkUrl);
  await tester.enterText(gptPromptField, "Test: <\$Q>");
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  final Finder saveButton = find.text("Save", skipOffstage: false);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();

  // Return home.
  final Finder backButton = find.byIcon(Icons.arrow_back);
  await tester.tap(backButton);
  await tester.pumpAndSettle();
}

Future<void> _deleteBasicDeeplink(
    WidgetTester tester, CommonFinders find) async {
  // Open deeplink configuration page.
  final Finder configureButton = find.text("Configure Deeplinks");
  await tester.tap(configureButton);
  await tester.pumpAndSettle();

  // Delete and confirm.
  final Finder itemCard = find.ancestor(
    of: find.text(_testDeeplinkName),
    matching: find.byType(Card),
  );
  final Finder deleteButton = find.descendant(
    of: itemCard,
    matching: find.byIcon(Icons.delete),
  );
  await tester.tap(deleteButton);
  await tester.pumpAndSettle();
  await tester.tap(find.text("Delete")); // Confirmation dialog button.
  await tester.pumpAndSettle();

  // Return home.
  final Finder backButton = find.byIcon(Icons.arrow_back);
  await tester.tap(backButton);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("end-to-end tests for deeplinks functionality", () {
    testWidgets("create deeplink, delete", (tester) async {
      await initApp(tester, find);
      expect(find.text("Configure Deeplinks"), findsOneWidget);

      // Open deeplink configuration page.
      final Finder configureButton = find.text("Configure Deeplinks");
      await tester.tap(configureButton);
      await tester.pumpAndSettle();
      expect(find.text("Configure Deeplinks"), findsOneWidget);
      expect(find.text("+ Add New Deeplink"), findsOneWidget);

      // Open new deeplink page.
      final Finder addDeeplinkButton = find.text("+ Add New Deeplink");
      await tester.tap(addDeeplinkButton);
      await tester.pumpAndSettle();
      expect(find.text("Edit Deeplink"), findsOneWidget);

      // Ensure empty submit fails.
      final Finder saveButton = find.text("Save", skipOffstage: false);
      await tester.tap(saveButton);
      await tester.pump();
      expect(find.text("All fields must be filled."), findsOneWidget);
      await tester.pumpAndSettle();

      // Enter valid deeplink data.
      final Finder nameField = find.ancestor(
        of: find.text("Name"),
        matching: find.byType(TextField),
      );
      final Finder deeplinkUrlField = find.ancestor(
        of: find.text("Deeplink URL"),
        matching: find.byType(TextField),
      );
      final Finder gptPromptField = find.ancestor(
        of: find.text("GPT Prompt"),
        matching: find.byType(TextField),
      );
      await tester.enterText(nameField, "My Test Item");
      await tester.enterText(deeplinkUrlField, "my-test-item");
      await tester.enterText(gptPromptField, "Test: <\$Q>");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Ensure page closed and new item is visible.
      expect(find.text("Configure Deeplinks"), findsOneWidget);
      expect(find.text("Edit Deeplink"), findsNothing);
      expect(find.text("My Test Item"), findsOneWidget);
      expect(find.text("aiyu://my-test-item"), findsOneWidget);

      // Click delete IconButton for that card.
      final Finder itemCard = find.ancestor(
        of: find.text("My Test Item"),
        matching: find.byType(Card),
      );
      final Finder deleteButton = find.descendant(
        of: itemCard,
        matching: find.byIcon(Icons.delete),
      );
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Ensure confirmation dialog shown, and cancel.
      expect(find.text("Delete Deeplink?"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Delete"), findsOneWidget);
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();
      expect(find.text("Delete Deeplink?"), findsNothing);

      // Item not removed.
      expect(find.text("My Test Item"), findsOneWidget);
      expect(find.text("aiyu://my-test-item"), findsOneWidget);

      // Try again.
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Ensure confirmation dialog shown, and confirm.
      expect(find.text("Delete Deeplink?"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Delete"), findsOneWidget);
      await tester.tap(find.text("Delete"));
      await tester.pumpAndSettle();
      expect(find.text("Delete Deeplink?"), findsNothing);

      // Item removed.
      expect(find.text("My Test Item"), findsNothing);
      expect(find.text("aiyu://my-test-item"), findsNothing);
    });

    testWidgets("log in, create basic deeplink, trigger, log out",
        (tester) async {
      final appKey = await initApp(tester, find);
      await logInAsTestUser(tester, find);
      await _createBasicDeeplink(tester, find);

      // Trigger deeplink.
      appKey.currentState!.triggerDeeplink(
          Uri.parse("aiyu://$_testDeeplinkUrl?q=What is the meaning of life?"));
      await tester.pumpAndSettle();

      // Ensure deeplink page shown.
      expect(find.text("Deeplink Action"), findsOneWidget);
      expect(find.text("Test: <What is the meaning of life?>"), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.east), findsOneWidget);
      expect(find.text("Close"), findsOneWidget);

      // Close button will close the app, so return home by setting null
      // deeplink URI instead.
      appKey.currentState!.triggerDeeplink(null);
      await tester.pumpAndSettle();
      expect(find.text("Deeplink Action"), findsNothing);

      await _deleteBasicDeeplink(tester, find);
      await signOutTestUser(tester, find);
    });
  });
}
