import "package:flutter/material.dart";
import "package:ai_yu/widgets/options_page_widget.dart";

class ChineseOptionsPage extends StatelessWidget {
  const ChineseOptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('zh'),
      child: Builder(
        builder: (context) {
          return const OptionsPageWidget();
        },
      ),
    );
  }
}
