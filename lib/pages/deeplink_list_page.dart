import "package:flutter/material.dart";

class DeeplinkListPage extends StatefulWidget {
  const DeeplinkListPage({Key? key}) : super(key: key);

  @override
  State<DeeplinkListPage> createState() => _DeeplinkListPageState();
}

class _DeeplinkListPageState extends State<DeeplinkListPage> {
  List<Deeplink> deepLinks = [
    Deeplink(link: "aiyu://action-one", name: "First description."),
    Deeplink(
        link: "aiyu://action-two", name: "Function description for action 2."),
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configure Deeplinks',
            style: TextStyle(color: theme.primaryColor)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Configure quick actions / deep-links to use in Anki flashcards.',
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: deepLinks.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    margin: const EdgeInsets.only(left: 30, right: 30, top: 20),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deepLinks[index].link,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(deepLinks[index].name),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Handle your edit action
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              // Handle your execute action
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Deeplink {
  final String link;
  final String name;

  Deeplink({required this.link, required this.name});
}
