import 'package:ai_yu/data_structures/gpt_mode.dart';
import 'package:flutter/material.dart';

String decideMission({required Locale locale, required GPTMode mode}) {
  late final String languageName;
  switch (locale) {
    case const Locale('zh'):
      languageName = "Chinese";
      break;
    case const Locale('ko'):
      languageName = "Korean";
      break;
    case const Locale('en'):
      languageName = "English";
    default:
      throw UnimplementedError(
          "Currently only Chinese, Korean and English are implemented.");
  }

  switch (mode) {
    case GPTMode.languagePracticeQuestionMode:
    case GPTMode.languagePracticeConversationMode:
      return """
The user is studying $languageName, and you are to help them improve their
language skills. For each prompt, before giving your response, first provide
feedback on how they built their sentence. In English, explain very briefly, and
in point form, any issues with their sentence, or how they could have made it
sound more natural. Then output "\n\n----\n\n", followed by a more natural
version of their sentence / question that would have been better, then
"\n\n----\n\n" again, followed by your normal response you would've provided if
you didn't get these special instructions. Try to limit your responses to fairly
concise answers.
""";
    default:
      throw UnimplementedError(
          "Currently, only question and conversation modes are implemented.");
  }
}
