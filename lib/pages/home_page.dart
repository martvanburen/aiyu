import 'package:ai_yu/widgets/home_page/conversation_launch_dialog_widget.dart';
import "package:ai_yu/pages/home/deeplink_list_page.dart";
import "package:ai_yu/widgets/home_page/conversation_quick_launch_widget.dart";
import "package:ai_yu/widgets/home_page/wallet_display_widget.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ConversationLaunchDialogWidgetState>
      conversationLaunchDialogWidgetKey =
      GlobalKey<ConversationLaunchDialogWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(" | ${AppLocalizations.of(context)!.subtitle}"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(30.0),
              child: WalletDisplayWidget(),
            ),
            Divider(
              height: 60,
              indent: 60,
              endIndent: 60,
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("Start Conversation"),
                      content: ConversationLaunchDialogWidget(
                        key: conversationLaunchDialogWidgetKey,
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FilledButton(
                          child: const Text("Start"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            conversationLaunchDialogWidgetKey.currentState!
                                .startConversation(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        "Conversation Practice",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        "Practice chatting in your desired language, and easily add new words to Anki.",
                      ),
                      const ConversationQuickLaunchWidget(),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DeeplinkListPage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        "Deeplink Actions",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                          "Configure quick actions / deep-links to use in Anki flashcards."),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
