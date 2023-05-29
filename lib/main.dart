import 'package:flutter/material.dart';

void main() {
  runApp(const AIYUApp());
}

class AIYUApp extends StatelessWidget {
  const AIYUApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI-YU',
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
  _MainScreenState createState() => _MainScreenState();
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
        title: const Text('GPT Language Practice'),
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'English'),
            Tab(text: '한국어'),
            Tab(text: '中文'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          EnglishPage(),
          KoreanPage(),
          ChinesePage(),
        ],
      ),
    );
  }
}

class EnglishPage extends StatelessWidget {
  const EnglishPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageWidget(
        title: "English",
        questionMode: "Question Mode",
        conversationMode: "Conversation Mode");
  }
}

class KoreanPage extends StatelessWidget {
  const KoreanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageWidget(
        title: "한국어", questionMode: "질문 모드", conversationMode: "대화 모드");
  }
}

class ChinesePage extends StatelessWidget {
  const ChinesePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageWidget(
        title: "中文", questionMode: "问题模式", conversationMode: "对话模式");
  }
}

class PageWidget extends StatelessWidget {
  final String title;
  final String questionMode;
  final String conversationMode;

  const PageWidget(
      {Key? key,
      required this.title,
      required this.questionMode,
      required this.conversationMode})
      : super(key: key);

  void _navigateToPage(BuildContext context, String mode) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ModePage(mode: mode)));
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
              _navigateToPage(context, questionMode);
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
              _navigateToPage(context, conversationMode);
            },
            child: Text(conversationMode, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class ModePage extends StatelessWidget {
  final String mode;

  const ModePage({Key? key, required this.mode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Back'),
        ),
      ),
    );
  }
}
