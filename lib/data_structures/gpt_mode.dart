import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter/material.dart';

enum GPTMode { conversationMode, deeplinkActionMode }

String gptModeDisplayName(
    {required GPTMode mode, required BuildContext context}) {
  switch (mode) {
    case GPTMode.conversationMode:
      return AppLocalizations.of(context)!.questionMode;
    case GPTMode.deeplinkActionMode:
      return AppLocalizations.of(context)!.conversationMode;
    default:
      throw UnimplementedError("gptModeDisplayName not implemented for $mode.");
  }
}
