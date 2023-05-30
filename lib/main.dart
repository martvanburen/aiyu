import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:http/http.dart" as http;

Future<void> main() async {
  await dotenv.load();
  runApp(const AIYUApp());
}

Future<String> callGptAPI(String prompt) async {
  // TODO(Mart):
  // . Using dotenv to store the API key is not secure. Eventually
  // . this app should be upgraded to communicate with a backend server,
  // . which will then also hold the API key and make the calls for us.
  const String url = "https://api.openai.com/v1/chat/completions";
  final response = await http.post(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${dotenv.env["OPENAI_KEY"]}",
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content": prompt,
        },
      ],
      "max_tokens": 100,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(utf8.decode(response.bodyBytes));
    return data["choices"][0]["message"]["content"].trim();
  } else {
    throw Exception("Failed to call GPT API: '${response.body}'.");
  }
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

class OptionsPageWidget extends StatelessWidget {
  final String title;
  final String questionMode;
  final String conversationMode;

  const OptionsPageWidget(
      {Key? key,
      required this.title,
      required this.questionMode,
      required this.conversationMode})
      : super(key: key);

  void _navigateToPage(BuildContext context, String mode, Locale locale) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LanguagePracticePage(mode: mode, locale: locale)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 150.0,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            onPressed: () {
              _navigateToPage(
                  context, questionMode, Localizations.localeOf(context));
            },
            child: Text(questionMode, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20.0),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 150.0,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            onPressed: () {
              _navigateToPage(
                  context, conversationMode, Localizations.localeOf(context));
            },
            child: Text(conversationMode, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class LanguagePracticePage extends StatefulWidget {
  final String mode;
  final Locale locale;

  const LanguagePracticePage(
      {Key? key, required this.mode, required this.locale})
      : super(key: key);

  @override
  State<LanguagePracticePage> createState() => _LanguagePracticePageState();
}

class _LanguagePracticePageState extends State<LanguagePracticePage> {
  String gptResponse = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getGptResponse();
  }

  void getGptResponse() async {
    String prompt =
        "Can you help me practice the language I'm learning in ${widget.mode} mode?";
    String response = await callGptAPI(prompt);
    setState(() {
      gptResponse = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Localizations.override(
      context: context,
      locale: widget.locale,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.mode),
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                      ),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(child: Text(gptResponse)),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(20.0)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.done),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
