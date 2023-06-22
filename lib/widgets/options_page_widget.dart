import "package:ai_yu/data_structures/gpt_mode.dart";
import "package:flutter/material.dart";
import "package:ai_yu/pages/language_practice_page.dart";

class OptionsPageWidget extends StatelessWidget {
  const OptionsPageWidget({Key? key}) : super(key: key);

  void _navigateToPage(BuildContext context, GPTMode mode, Locale locale) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LanguagePracticePage(mode: mode, locale: locale)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 150.0,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            onPressed: () {
              _navigateToPage(context, GPTMode.languagePracticeQuestionMode,
                  Localizations.localeOf(context));
            },
            child: Text(
                gptModeDisplayName(
                    mode: GPTMode.languagePracticeQuestionMode,
                    context: context),
                style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20.0),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 150.0,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            onPressed: () {
              _navigateToPage(context, GPTMode.languagePracticeConversationMode,
                  Localizations.localeOf(context));
            },
            child: Text(
                gptModeDisplayName(
                    mode: GPTMode.languagePracticeConversationMode,
                    context: context),
                style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
