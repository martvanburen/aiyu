import "package:ai_yu/pages/home/conversation_launch_page.dart";
import "package:ai_yu/pages/home/deeplink_list_page.dart";
import "package:ai_yu/widgets/home_page/wallet_display_widget.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _children = [
    const ConversationLaunchPage(),
    const DeeplinkListPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _children.length);
    _tabController.addListener(() {
      setState(() {});
    });
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
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(30.0),
            child: WalletDisplayWidget(),
          ),
          TabBar(
            controller: _tabController,
            tabs: const <Tab>[
              Tab(text: 'Conversation Practice'),
              Tab(text: 'Deeplink Actions'),
            ],
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: _children,
          )),
          Divider(
            height: 0,
            thickness: 2,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
