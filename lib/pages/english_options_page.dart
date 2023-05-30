import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:gpt_korean_practice/widgets/options_page_widget.dart";

class EnglishOptionsPage extends StatelessWidget {
  const EnglishOptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('en'),
      child: Builder(
        builder: (context) {
          return OptionsPageWidget(
              title: AppLocalizations.of(context)!.tab_english,
              questionMode: AppLocalizations.of(context)!.questionMode,
              conversationMode: AppLocalizations.of(context)!.conversationMode);
        },
      ),
    );
  }
}
