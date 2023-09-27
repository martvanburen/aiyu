import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

import "test_utils.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("end-to-end tests for conversation functionality", () {
    testWidgets(
        "log in, start chinese conversation, select word, open deeplink, log out",
        (tester) async {
      await initApp(tester, find);
      await logInAsTestUser(tester, find);
      await waitForWalletBalanceNonZero(tester, find);
      expect(find.text("Conversation Practice"), findsOneWidget);

      // Open conversation start dialog.
      await tester.tap(find.text("Conversation Practice"));
      await tester.pumpAndSettle();
      expect(find.text("Start Conversation"), findsOneWidget);
      final Finder languageDropdown =
          find.byKey(const ValueKey("languageDropdown"));
      expect(languageDropdown, findsOneWidget);
      final Finder automaticModeCheckbox =
          find.byKey(const ValueKey("automaticModeCheckbox"));
      expect(automaticModeCheckbox, findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Start"), findsOneWidget);

      // Select Chinese, and enable auto-conversation mode.
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Chinese"));
      await tester.pumpAndSettle();
      await tester.tap(automaticModeCheckbox);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Start"));
      await tester.pumpAndSettle();

      // Wait for user to accept permissions (10s).
      int i = 0;
      while (find.text("Listening...").evaluate().isEmpty) {
        if (i++ > 20) {
          fail("Microphone permissions were not accepted by tester.");
        }
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // >>>
        // Tester Accepts Mic Permissions
        // <<<
      }

      await tester.pump();

      // Verify that conversation page is open.
      expect(find.text("会话练习"), findsOneWidget);
      expect(find.text("你想讨论什么呢？"), findsOneWidget);
      expect(find.text("Listening..."), findsOneWidget);
      expect(find.text("AUTO\nMODE"), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      // Cancel speech input.
      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pump();
      expect(find.textContaining("Auto mode disabled."), findsOneWidget);
      await tester.pumpAndSettle();

      // Quick GPT Q&A in Chinese.
      await tester.enterText(find.byType(TextField), "左边的相反是什么？");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(find.textContaining("右边"), findsOneWidget);

      // Wait one second to let message start speaking.
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);

      // If we start playing the other message, the currently speaking one
      // should stop.
      await tester.tap(find.byIcon(Icons.play_arrow).last);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);

      // Pressing the mic should stop all speaking messages.
      await tester.tap(find.byIcon(Icons.mic_none));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.stop), findsNothing);
      expect(find.byIcon(Icons.play_arrow), findsNWidgets(2));
      expect(find.text("Listening..."), findsOneWidget);

      // Stop listening.
      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();

      // There should be two messages that can be viewed in detail.
      expect(find.byIcon(Icons.east), findsNWidgets(2));

      // Open the first one (last in finder results, since ListView displays in
      // reverse).
      await tester.tap(find.byIcon(Icons.east).last);
      await tester.pumpAndSettle();

      // Check selection page opened.
      expect(find.text("GPT Response"), findsOneWidget);
      expect(find.text("Selection:"), findsOneWidget);
      expect(find.text("Translation:"), findsOneWidget);
      expect(find.text("Close"), findsOneWidget);

      // Wait for translation to complete (5s).
      int j = 0;
      while (find.text("Translating...").evaluate().isNotEmpty) {
        if (j++ > 5) {
          fail("Translation did not complete.");
        }
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
      expect(find.text("你想讨论什么呢？"), findsWidgets);
      expect(find.textContaining("discuss"), findsOneWidget);

      // Tap translation, and close.
      await tester.tap(find.textContaining("discuss"));
      await tester.pumpAndSettle();
      expect(find.text("Translation:"), findsNWidgets(2));
      expect(find.text("Close"), findsNWidgets(2));
      await tester.tap(find.text("Close").last);
      await tester.pumpAndSettle();

      // Open deeplink action.
      await tester.tap(find.textContaining("Actions"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Open as deeplink"));
      await tester.pumpAndSettle();
      expect(find.text("Select a Deeplink"), findsOneWidget);
      expect(find.text("To Pinyin"), findsOneWidget);
      await tester.tap(find.text("To Pinyin"));
      await tester.pumpAndSettle();

      // Check deeplink action page, and return.
      expect(find.text("Deeplink Action"), findsOneWidget);
      expect(find.textContaining("xiǎng"), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Close selection page.
      await tester.tap(find.text("Close"));
      await tester.pumpAndSettle();

      // Go home and check Chinese added to recents on home page.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text("Recent:"), findsOneWidget);
      expect(find.text("Chinese"), findsOneWidget);

      // Sign out.
      await signOutTestUser(tester, find);
    });
  });
}
