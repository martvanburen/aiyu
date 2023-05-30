import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:gpt_korean_practice/widgets/options_page_widget.dart";

class ChineseOptionsPage extends StatelessWidget {
  const ChineseOptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('zh'),
      child: Builder(
        builder: (context) {
          return OptionsPageWidget(
              title: AppLocalizations.of(context)!.tab_chinese,
              questionMode: AppLocalizations.of(context)!.questionMode,
              conversationMode: AppLocalizations.of(context)!.conversationMode);
        },
      ),
    );
  }
}
