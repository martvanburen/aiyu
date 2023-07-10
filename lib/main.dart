import "dart:io";

import "package:ai_yu/data_structures/global_state/deeplinks_model.dart";
import "package:ai_yu/data_structures/global_state/preferences_model.dart";
import "package:ai_yu/data_structures/global_state/wallet_model.dart";
import 'package:ai_yu/pages/home_page.dart';
import 'package:ai_yu/pages/conversation_page.dart';
import "package:ai_yu/utils/supported_languages_provider.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:flutter_shortcuts/flutter_shortcuts.dart";
import "package:provider/provider.dart";

Future<void> main() async {
  await dotenv.load();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => PreferencesModel()),
      ChangeNotifierProvider(create: (context) => DeeplinksModel()),
      ChangeNotifierProvider(create: (context) => WalletModel()),
    ],
    child: const AiYuApp(),
  ));
}

class AiYuApp extends StatefulWidget {
  const AiYuApp({super.key});

  @override
  State<AiYuApp> createState() => _AiYuAppState();
}

class _AiYuAppState extends State<AiYuApp> {
  String action = '';
  final FlutterShortcuts flutterShortcuts = FlutterShortcuts();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      flutterShortcuts.initialize();
      // Handle incoming app shortcuts.
      handleFlutterShortcuts();
      // Update app shortcuts when recent languages change.
      Provider.of<PreferencesModel>(context, listen: false)
          .addListener(setFlutterShortcutActions);
    }
  }

  void setFlutterShortcutActions() {
    List<String> recentLanguages =
        Provider.of<PreferencesModel>(context, listen: false).recentLanguages;
    flutterShortcuts.setShortcutItems(
        shortcutItems: recentLanguages
            .asMap()
            .map(
              (i, l) => MapEntry(
                  i,
                  ShortcutItem(
                    id: i.toString(),
                    action: "start_conversation_$l",
                    shortLabel:
                        "Start ${SupportedLanguagesProvider.getDisplayName(l)} Conversation",
                    icon: "ic_launcher",
                    shortcutIconAsset: ShortcutIconAsset.androidAsset,
                  )),
            )
            .values
            .toList());
  }

  void handleFlutterShortcuts() {
    flutterShortcuts.listenAction((String incomingAction) {
      setState(() {
        action = incomingAction;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    late final Widget home;
    if (action.startsWith("start_conversation_")) {
      final language = action.substring("start_conversation_".length);
      home = LanguagePracticePage(language: language);
    } else {
      home = const HomePage();
    }
    return MaterialApp(
      title: "AI-YU",
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,

        // Make all buttons square by default.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
      ),
      home: home,
    );
  }
}
