import "package:flutter/material.dart";
import "package:gpt_korean_practice/pages/language_practice_page.dart";

class OptionsPageWidget extends StatelessWidget {
  final String title;
  final String questionMode;
  final String conversationMode;

  const OptionsPageWidget(
      {Key? key,
      required this.title,
      required this.questionMode,
      required this.conversationMode})
      : super(key: key);

  void _navigateToPage(BuildContext context, String mode, Locale locale) {
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
              _navigateToPage(
                  context, questionMode, Localizations.localeOf(context));
            },
            child: Text(questionMode, style: const TextStyle(fontSize: 16)),
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
              _navigateToPage(
                  context, conversationMode, Localizations.localeOf(context));
            },
            child: Text(conversationMode, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
