import 'package:ai_yu/data/state_models/preferences_model.dart';
import "package:ai_yu/utils/event_recorder.dart";
import "package:ai_yu/utils/supported_languages_provider.dart";
import "package:flutter/material.dart";
import "package:ai_yu/pages/conversation_page.dart";
import "package:provider/provider.dart";

class ConversationLaunchDialog extends StatefulWidget {
  const ConversationLaunchDialog({super.key});

  @override
  State<ConversationLaunchDialog> createState() =>
      ConversationLaunchDialogState();
}

class ConversationLaunchDialogState extends State<ConversationLaunchDialog> {
  String _selectedLanguage = SupportedLanguagesProvider.defaultLanguageCode;

  @override
  void initState() {
    super.initState();
  }

  Future _startConversation(BuildContext context) {
    final preferences = Provider.of<PreferencesModel>(context, listen: false);
    preferences.addRecentLanguage(_selectedLanguage);
    EventRecorder.conversationStart(_selectedLanguage,
        automaticMode: preferences.isAutoConversationMode, quickLaunch: false);
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LanguagePracticePage(language: _selectedLanguage)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Start Conversation"),
      content:
          Consumer<PreferencesModel>(builder: (context, preferences, child) {
        return SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Divider(thickness: 2, color: Theme.of(context).dividerColor),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(children: [
                    const Text("Language:"),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedLanguage,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLanguage = newValue!;
                          });
                        },
                        items:
                            SupportedLanguagesProvider.getSupportedLanguages()
                                .map<DropdownMenuItem<String>>(
                                    (String language) {
                          return DropdownMenuItem<String>(
                            value: language,
                            child: Text(
                                SupportedLanguagesProvider.getDisplayName(
                                    language)),
                          );
                        }).toList(),
                      ),
                    ),
                  ]),
                ),
                const Divider(
                  thickness: 2,
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  indent: 7,
                  endIndent: 7,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: const EdgeInsets.all(0.0),
                          title: const Text(
                            "Automatic mode.",
                            style: TextStyle(fontSize: 14),
                          ),
                          value: preferences.isAutoConversationMode,
                          onChanged: (newValue) {
                            preferences.setAutoConversationMode(newValue!);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Automatic mode."),
                                content: const Text("""
If enabled, the app will automatically:
- Start listening when it's your turn to speak.
- Submit if it's confident it understood you correctly."""),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Divider(thickness: 2, color: Theme.of(context).dividerColor),
              ],
            ));
      }),
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
            _startConversation(context);
          },
        ),
      ],
    );
  }
}
