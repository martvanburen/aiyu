import "package:ai_yu/main.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("end-to-end tests for login & wallet functionality", () {
    testWidgets("basic wallet info", (tester) async {
      await tester.pumpWidget(await buildApp());
      await tester.pumpAndSettle();

      expect(find.text("0.0¢"), findsOneWidget);
      expect(find.text("Add 50¢"), findsOneWidget);

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
  });
}
