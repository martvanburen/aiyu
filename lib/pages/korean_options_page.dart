import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:ai_yu/widgets/options_page_widget.dart";

class KoreanOptionsPage extends StatelessWidget {
  const KoreanOptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('ko'),
      child: Builder(
        builder: (context) {
          return OptionsPageWidget(
              title: AppLocalizations.of(context)!.tab_korean,
              questionMode: AppLocalizations.of(context)!.questionMode,
              conversationMode: AppLocalizations.of(context)!.conversationMode);
        },
      ),
    );
  }
}
