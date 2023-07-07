import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ai_yu/data_structures/gpt_mode.dart';
import 'package:ai_yu/pages/conversation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  Widget Function(BuildContext) expandedValue;
  String headerValue;
  bool isExpanded;
}

class ConversationLaunchPage extends StatefulWidget {
  const ConversationLaunchPage({super.key});

  @override
  State<ConversationLaunchPage> createState() => _ConversationLaunchPage();
}

class _ConversationLaunchPage extends State<ConversationLaunchPage> {
  bool _isConversationMode = false;
  Locale _selectedLocale = const Locale('en', 'English');
  List<String> _recentLanguages = ['-', '-', '-'];
  late int _currentOpenPanelIndex;
  final _panelItems = <Item>[];
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

    _currentOpenPanelIndex = 0;
    _panelItems.add(Item(
      expandedValue: _buildQuickLaunch,
      headerValue: "Quick Launch",
      isExpanded: true,
    ));
    _panelItems.add(Item(
      expandedValue: _buildManualLaunch,
      headerValue: "New Conversation",
      isExpanded: false,
    ));
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
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildHeaderText(context),
            _buildExpansionPanelList(),
          ],
        ));
  }

  Widget _buildHeaderText(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(30.0),
      child: Text(
        "Practice chatting in your desired language, and easily add new words to Anki.",
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildExpansionPanelList() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _panelItems[_currentOpenPanelIndex].isExpanded = false;
              _currentOpenPanelIndex = index;
              _panelItems[_currentOpenPanelIndex].isExpanded = !isExpanded;
            });
          },
          elevation: 2,
          expandedHeaderPadding: const EdgeInsets.all(0.0),
          animationDuration: const Duration(milliseconds: 400),
          children: _panelItems.map<ExpansionPanel>((Item item) {
            return ExpansionPanel(
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Column(children: [
                  ListTile(
                    title: Text(
                      item.headerValue,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ]);
              },
              body: Padding(
                  padding: const EdgeInsets.only(
                      top: 0.0, left: 20.0, right: 20.0, bottom: 10.0),
                  child: item.expandedValue(context)),
              isExpanded: item.isExpanded,
              backgroundColor: Colors.white,
            );
          }).toList(),
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

  Widget _buildManualLaunch(BuildContext context) {
    return Column(children: [
      Row(children: [
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
      Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.all(0.0),
              title: const Text(
                "Conversation mode.",
                style: TextStyle(fontSize: 15),
              ),
              value: _isConversationMode,
              onChanged: (newValue) {
                setState(() {
                  _isConversationMode = newValue!;
                  _prefs?.setBool('isConversationMode', _isConversationMode);
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
          ElevatedButton(
            onPressed: () => _navigateToPage(context, _selectedLocale),
            child: const Text('Start'),
          ),
        ],
      ),
    ]);
  }
}
