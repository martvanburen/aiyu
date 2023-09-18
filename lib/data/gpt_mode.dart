import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

enum GPTMode { conversationPracticeMode, deeplinkActionMode }

String gptModeDisplayName(
    {required GPTMode mode, required BuildContext context}) {
  switch (mode) {
    case GPTMode.conversationPracticeMode:
      return AppLocalizations.of(context)?.conversation_page_title ??
          "Conversation Practice";
    case GPTMode.deeplinkActionMode:
      return "Deeplink Action";
    default:
      throw UnimplementedError("gptModeDisplayName not implemented for $mode.");
  }
}
