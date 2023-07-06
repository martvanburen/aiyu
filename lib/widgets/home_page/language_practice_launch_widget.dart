import 'package:flutter/material.dart';
import 'package:ai_yu/data_structures/gpt_mode.dart';
import 'package:ai_yu/pages/language_practice_page.dart';

class LanguagePracticeLaunchWidget extends StatelessWidget {
  const LanguagePracticeLaunchWidget({Key? key}) : super(key: key);

  void _navigateToPage(BuildContext context, Locale locale) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LanguagePracticePage(
                mode: GPTMode.languagePracticeConversationMode,
                locale: locale)));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _navigateToPage(context, const Locale('en')),
            child: const Text('Start Conversation in English'),
          ),
          ElevatedButton(
            onPressed: () => _navigateToPage(context, const Locale('ko')),
            child: const Text('Start Conversation in Korean'),
          ),
          ElevatedButton(
            onPressed: () => _navigateToPage(context, const Locale('zh')),
            child: const Text('Start Conversation in Chinese'),
          ),
        ],
      ),
    );
  }
}
