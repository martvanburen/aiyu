import "package:ai_yu/widgets/home_page/language_practice_launch_widget.dart";
import "package:ai_yu/widgets/home_page/wallet_display_widget.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Padding(
                padding: EdgeInsets.all(30.0), child: WalletDisplayWidget()),
            Divider(
              height: 0,
              thickness: 2,
              color: Theme.of(context).primaryColor,
            ),
            const LanguagePracticeLaunchWidget(),
            Divider(
              height: 0,
              thickness: 2,
              color: Theme.of(context).primaryColor,
            ),
            Padding(
                padding: const EdgeInsets.all(30.0),
                child: _buildDeeplinkConfigurationLaunchButton(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeeplinkConfigurationLaunchButton(BuildContext context) {
    return Column(children: [
      const Center(
        child: Text(
          "Configure deeplinks for Anki flashcards:",
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width / 2.0,
        height: 40,
        child: const Divider(color: Colors.grey),
      ),
      const Center(
        child: ElevatedButton(
          onPressed: null,
          child: Text('Configure Deeplinks.'),
        ),
      ),
    ]);
  }
}
