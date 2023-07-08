import 'package:ai_yu/data_structures/global_state/deeplinks_model.dart';
import 'package:ai_yu/pages/deeplink_edit_page.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class DeeplinkListPage extends StatefulWidget {
  const DeeplinkListPage({Key? key}) : super(key: key);

  @override
  State<DeeplinkListPage> createState() => _DeeplinkListPageState();
}

class _DeeplinkListPageState extends State<DeeplinkListPage> {
  void addDeeplink() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeeplinkEditPage(),
      ),
    );
  }

  void editDeeplink(DeeplinkConfig deeplink) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeeplinkEditPage(deeplink: deeplink),
      ),
    );
  }

  void deleteDeeplink(int index, DeeplinksModel deeplinks) async {
    bool? delete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Deeplink?"),
        content:
            const Text("Are you sure you want to delete this deeplink action?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (delete != null && delete) {
      deeplinks.removeIndex(index);
    }
  }

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
                builder: (context, deeplinks, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10.0),
                    itemCount: deeplinks.get.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      // Use this slight hack to append a manual element to the
                      // end of the list (without it having to be beyond the
                      // Expanded element).
                      if (index == deeplinks.get.length) {
                        return Center(
                          child: TextButton(
                            onPressed: () => addDeeplink(),
                            child: const Text("+ Add New Deeplink"),
                          ),
                        );
                      } else {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deeplinks.get[index].url,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(deeplinks.get[index].name),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      editDeeplink(deeplinks.get[index]),
                                ),
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        deleteDeeplink(index, deeplinks)),
                              ],
                            ),
                          ),
                        );
                      }
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
