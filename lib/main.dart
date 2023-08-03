import "dart:async";
import "dart:io";

import 'package:ai_yu/data/state_models/aws_model.dart';
import 'package:ai_yu/data/state_models/deeplinks_model.dart';
import 'package:ai_yu/data/state_models/preferences_model.dart';
import 'package:ai_yu/data/state_models/wallet_model.dart';
import "package:ai_yu/pages/deeplink_page.dart";
import "package:ai_yu/pages/home_page.dart";
import "package:ai_yu/pages/conversation_page.dart";
import "package:ai_yu/utils/supported_languages_provider.dart";
import "package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart";
import "package:amplify_api/amplify_api.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:flutter_shortcuts/flutter_shortcuts.dart";
import "package:provider/provider.dart";
import "package:uni_links/uni_links.dart";

import 'awsconfiguration.dart';

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(),
      AmplifyAnalyticsPinpoint(),
    ]);
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    safePrint("ERROR: Failed to initialize Amplify. $e.");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => PreferencesModel()),
      ChangeNotifierProvider(create: (context) => DeeplinksModel()),
      ChangeNotifierProvider(create: (context) => AWSModel(), lazy: false),
      ChangeNotifierProxyProvider<AWSModel, WalletModel>(
        create: (context) => WalletModel(null, null),
        update: (context, auth, previousWallet) =>
            WalletModel(auth, previousWallet),
      ),
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
  // App shortcuts & deeplinks.
  final FlutterShortcuts _flutterShortcuts = FlutterShortcuts();
  StreamSubscription? _deeplinkSubscription;
  String? _appOpenFlutterShortcutsAction;
  Uri? _appOpenDeeplink;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _initializeFlutterAppShortcuts();
      _initializeDeeplinks();
    }
  }

  void _initializeFlutterAppShortcuts() {
    _flutterShortcuts.initialize();
    // Handle incoming app shortcuts
    _flutterShortcuts.listenAction((String incomingAction) {
      setState(() {
        _appOpenFlutterShortcutsAction = incomingAction;
      });
    });
    // Update app shortcuts when recent languages change.
    Provider.of<PreferencesModel>(context, listen: false)
        .addListener(_setFlutterShortcutActions);
  }

  void _setFlutterShortcutActions() {
    List<String> recentLanguages =
        Provider.of<PreferencesModel>(context, listen: false).recentLanguages;
    _flutterShortcuts.setShortcutItems(
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

  void _initializeDeeplinks() async {
    // Check for initial URI from app launch.
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null && initialUri.scheme == "aiyu") {
        setState(() {
          _appOpenDeeplink = initialUri;
        });
      }
    } on PlatformException {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to open deeplink.")));
      });
    }

    // Subscribe to future links.
    _deeplinkSubscription = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == "aiyu") {
        setState(() {
          _appOpenDeeplink = uri;
        });
      }
    }, onError: (err) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to open deeplink.")));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Decide home based on app shortcuts & deeplinks.
    late final Widget home;
    if (_appOpenFlutterShortcutsAction?.startsWith("start_conversation_") ??
        false) {
      final language = _appOpenFlutterShortcutsAction!
          .substring("start_conversation_".length);
      home = LanguagePracticePage(language: language);
    } else if (_appOpenDeeplink != null) {
      home = DeeplinkPage.fromUri(uri: _appOpenDeeplink!);
    } else {
      home = const HomePage();
    }

    return MaterialApp(
      title: "AI-YU",
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _buildAppTheme(),
      home: home,
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
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
    );
  }

  @override
  void dispose() {
    _deeplinkSubscription?.cancel();
    super.dispose();
  }
}
