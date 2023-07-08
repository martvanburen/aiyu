import 'package:ai_yu/data_structures/global_state/deeplinks_model.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class DeeplinkListPage extends StatefulWidget {
  const DeeplinkListPage({Key? key}) : super(key: key);

  @override
  State<DeeplinkListPage> createState() => _DeeplinkListPageState();
}

class _DeeplinkListPageState extends State<DeeplinkListPage> {
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
              child: Consumer<DeeplinksModel>(
                builder: (context, deeplinksModel, child) {
                  return ListView.builder(
                    itemCount: deeplinksModel.deeplinks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        margin:
                            const EdgeInsets.only(left: 30, right: 30, top: 20),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deeplinksModel.deeplinks[index].url,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(deeplinksModel
                                    .deeplinks[index].description),
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
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  // Handle your execute action
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
