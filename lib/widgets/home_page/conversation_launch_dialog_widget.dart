import "package:ai_yu/utils/supported_languages_provider.dart";
import "package:flutter/material.dart";
import "package:ai_yu/data_structures/gpt_mode.dart";
import "package:ai_yu/pages/conversation_page.dart";
import "package:shared_preferences/shared_preferences.dart";

class ConversationLaunchDialogWidget extends StatefulWidget {
  const ConversationLaunchDialogWidget({super.key});

  @override
  State<ConversationLaunchDialogWidget> createState() =>
      ConversationLaunchDialogWidgetState();
}

class ConversationLaunchDialogWidgetState
    extends State<ConversationLaunchDialogWidget> {
  bool _isConversationMode = false;
  String _selectedLanguageCode = SupportedLanguagesProvider.defaultLanguageCode;
  List<String> _recentLanguages = [];
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isConversationMode = _prefs?.getBool("isConversationMode") ?? false;
      _recentLanguages = _prefs?.getStringList("recentLanguages") ?? [];
    });
  }

  Future startConversation(BuildContext context) {
    _updateRecentLanguages(_selectedLanguageCode);
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LanguagePracticePage(
                mode: _isConversationMode
                    ? GPTMode.languagePracticeConversationMode
                    : GPTMode.languagePracticeQuestionMode,
                locale: Locale(_selectedLanguageCode))));
  }

  void _updateRecentLanguages(String languageCode) {
    if (!_recentLanguages.contains(languageCode)) {
      _recentLanguages.add(languageCode);
    }
    // Clear older entries until only must recent 2 remain.
    while (_recentLanguages.length > 2) {
      _recentLanguages.removeAt(0);
    }
    _prefs?.setStringList("recentLanguages", _recentLanguages);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Divider(thickness: 2, color: Theme.of(context).dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(children: [
                const Text("Language:"),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedLanguageCode,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguageCode = newValue!;
                      });
                    },
                    items: SupportedLanguagesProvider.getSupportedLanguages()
                        .map<DropdownMenuItem<String>>((String languageCode) {
                      return DropdownMenuItem<String>(
                        value: languageCode,
                        child: Text(SupportedLanguagesProvider.getDisplayName(
                            languageCode)),
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
                        "Conversation mode.",
                        style: TextStyle(fontSize: 14),
                      ),
                      value: _isConversationMode,
                      onChanged: (newValue) {
                        setState(() {
                          _isConversationMode = newValue!;
                          _prefs?.setBool(
                              "isConversationMode", _isConversationMode);
                        });
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
                            title: const Text("Conversation mode."),
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
  }
}
