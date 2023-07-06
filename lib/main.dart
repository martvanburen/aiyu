import "dart:io";

import "package:ai_yu/data_structures/gpt_mode.dart";
import "package:ai_yu/pages/home_page.dart";
import "package:ai_yu/pages/language_practice_page.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:flutter_shortcuts/flutter_shortcuts.dart";

Future<void> main() async {
  await dotenv.load();
  runApp(const AiYuApp());
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
      setFlutterShortcutActions();
      handleFlutterShortcuts();
    }
  }

  void setFlutterShortcutActions() {
    flutterShortcuts.setShortcutItems(
      shortcutItems: <ShortcutItem>[
        const ShortcutItem(
          id: "1",
          action: "start_conversation_en",
          shortLabel: "Start Conversation",
          icon: "ic_launcher",
          shortcutIconAsset: ShortcutIconAsset.androidAsset,
        ),
        const ShortcutItem(
          id: "2",
          action: "start_conversation_ko",
          shortLabel: "대화 시작",
          icon: "ic_launcher",
          shortcutIconAsset: ShortcutIconAsset.androidAsset,
        ),
        const ShortcutItem(
          id: "3",
          action: "start_conversation_zh",
          shortLabel: "开始对话",
          icon: "ic_launcher",
          shortcutIconAsset: ShortcutIconAsset.androidAsset,
        ),
      ],
    );
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
    switch (action) {
      case "start_conversation_en":
        home = const LanguagePracticePage(
            mode: GPTMode.languagePracticeConversationMode,
            locale: Locale('en'));
        break;
      case "start_conversation_ko":
        home = const LanguagePracticePage(
            mode: GPTMode.languagePracticeConversationMode,
            locale: Locale('ko'));
        break;
      case "start_conversation_zh":
        home = const LanguagePracticePage(
            mode: GPTMode.languagePracticeConversationMode,
            locale: Locale('zh'));
        break;
      default:
        home = const HomePage();
        break;
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
