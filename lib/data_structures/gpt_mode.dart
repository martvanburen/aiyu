import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter/material.dart';

enum GPTMode { languagePracticeQuestionMode, languagePracticeConversationMode }

String gptModeDisplayName(
    {required GPTMode mode, required BuildContext context}) {
  switch (mode) {
    case GPTMode.languagePracticeConversationMode:
      return AppLocalizations.of(context)!.conversationMode;
    default:
      return AppLocalizations.of(context)!.questionMode;
  }
}
