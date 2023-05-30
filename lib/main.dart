import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:gpt_korean_practice/pages/chinese_options_page.dart";
import "package:gpt_korean_practice/pages/english_options_page.dart";
import "package:gpt_korean_practice/pages/korean_options_page.dart";

Future<void> main() async {
  await dotenv.load();
  runApp(const AIYUApp());
}

class AIYUApp extends StatelessWidget {
  const AIYUApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AI-YU",
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title),
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(text: AppLocalizations.of(context)!.tab_english),
            Tab(text: AppLocalizations.of(context)!.tab_korean),
            Tab(text: AppLocalizations.of(context)!.tab_chinese),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          EnglishOptionsPage(),
          KoreanOptionsPage(),
          ChineseOptionsPage(),
        ],
      ),
    );
  }
}
