import 'package:flutter/material.dart';

enum GPTMode { conversationPracticeMode, deeplinkActionMode }

String gptModeDisplayName(
    {required GPTMode mode, required BuildContext context}) {
  switch (mode) {
    case GPTMode.conversationPracticeMode:
      return "Conversation Practice";
    case GPTMode.deeplinkActionMode:
      return "Deeplink Action";
    default:
      throw UnimplementedError("gptModeDisplayName not implemented for $mode.");
  }
}
