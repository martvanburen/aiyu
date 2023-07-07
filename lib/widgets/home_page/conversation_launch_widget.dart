import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ai_yu/data_structures/gpt_mode.dart';
import 'package:ai_yu/pages/conversation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationLaunchWidget extends StatefulWidget {
  const ConversationLaunchWidget({super.key});

  @override
  State<ConversationLaunchWidget> createState() => _ConversationLaunchWidget();
}

class _ConversationLaunchWidget extends State<ConversationLaunchWidget> {
  bool _isConversationMode = false;
  Locale _selectedLocale = const Locale('en', 'English');
  List<String> _recentLanguages = ['-', '-', '-'];
  final _languageMap = {
    'en': 'English',
    'ko': 'Korean',
    'zh': 'Chinese',
  };
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isConversationMode = _prefs?.getBool('isConversationMode') ?? false;
      _recentLanguages =
          _prefs?.getStringList('recentLanguages') ?? ['-', '-', '-'];
    });
  }

  void _navigateToPage(BuildContext context, Locale locale) {
    _updateRecentLanguages(locale.languageCode);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LanguagePracticePage(
                mode: _isConversationMode
                    ? GPTMode.languagePracticeConversationMode
                    : GPTMode.languagePracticeQuestionMode,
                locale: _selectedLocale)));
  }

  void _updateRecentLanguages(String languageCode) {
    if (!_recentLanguages.contains(languageCode)) {
      _recentLanguages.removeAt(0);
      _recentLanguages.add(languageCode);
      _prefs?.setStringList('recentLanguages', _recentLanguages);
    }
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
                  child: DropdownButton<Locale>(
                    isExpanded: true,
                    value: _selectedLocale,
                    onChanged: (Locale? newValue) {
                      setState(() {
                        _selectedLocale = newValue!;
                      });
                    },
                    items: <Locale>[
                      const Locale('en', 'English'),
                      const Locale('ko', 'Korean'),
                      const Locale('zh', 'Chinese')
                    ].map<DropdownMenuItem<Locale>>((Locale value) {
                      return DropdownMenuItem<Locale>(
                        value: value,
                        child: Text(value.countryCode ?? value.languageCode),
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
                              'isConversationMode', _isConversationMode);
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
                                child: const Text('OK'),
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

  Widget _buildQuickLaunch(BuildContext context) {
    return Column(children: [
      LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _recentLanguages
              .map((language) => SizedBox(
                    width: max(0, (constraints.maxWidth / 3) - 5),
                    child: FilledButton(
                      onPressed: language == '-'
                          ? null
                          : () => _navigateToPage(context,
                              Locale(language, _languageMap[language])),
                      child: Text(language == '-'
                          ? '-'
                          : _languageMap[language] ?? language),
                    ),
                  ))
              .toList(),
        );
      }),
    ]);
  }
}
