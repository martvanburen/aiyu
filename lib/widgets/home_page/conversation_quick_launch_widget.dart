import "package:ai_yu/utils/supported_languages_provider.dart";
import "package:flutter/material.dart";
import "package:ai_yu/data_structures/gpt_mode.dart";
import "package:ai_yu/pages/conversation_page.dart";
import "package:shared_preferences/shared_preferences.dart";

class ConversationQuickLaunchWidget extends StatefulWidget {
  const ConversationQuickLaunchWidget({super.key});

  @override
  State<ConversationQuickLaunchWidget> createState() =>
      _ConversationQuickLaunchWidgetState();
}

class _ConversationQuickLaunchWidgetState
    extends State<ConversationQuickLaunchWidget> {
  bool _isConversationMode = false;
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

  void _navigateToPage(BuildContext context, Locale locale) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LanguagePracticePage(
                mode: _isConversationMode
                    ? GPTMode.languagePracticeConversationMode
                    : GPTMode.languagePracticeQuestionMode,
                locale: locale)));
  }

  @override
  Widget build(BuildContext context) {
    if (_recentLanguages.isEmpty) {
      // If no recent languages, don't display this widget.
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(
                child: Text(
              "Recent:",
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.grey),
            )),
            ..._recentLanguages
                .take(2)
                .map((language) => Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: SizedBox(
                          child: FilledButton(
                        onPressed: () =>
                            _navigateToPage(context, Locale(language)),
                        child: Text(SupportedLanguagesProvider.getDisplayName(
                            language)),
                      )),
                    ))
                .toList(),
          ],
        ),
      );
    }
  }
}
