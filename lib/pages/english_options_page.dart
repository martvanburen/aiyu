import "package:flutter/material.dart";
import "package:ai_yu/widgets/options_page_widget.dart";

class EnglishOptionsPage extends StatelessWidget {
  const EnglishOptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('en'),
      child: Builder(
        builder: (context) {
          return const OptionsPageWidget();
        },
      ),
    );
  }
}
