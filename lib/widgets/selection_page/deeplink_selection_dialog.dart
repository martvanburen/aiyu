import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:ai_yu/data/state_models/deeplinks_model.dart';
import "package:ai_yu/pages/deeplink_page.dart";

class DeeplinkSelectionDialog extends StatelessWidget {
  final String queryString;

  const DeeplinkSelectionDialog({super.key, required this.queryString});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeeplinksModel>(
      builder: (context, deeplinks, child) {
        return AlertDialog(
          title: const Text("Select a Deeplink"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: deeplinks.get.length,
              itemBuilder: (context, index) {
                final deeplink = deeplinks.get[index];
                return ListTile(
                  title: Text(deeplink.name),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DeeplinkPage(
                        deeplinkConfig: deeplink,
                        queryString: queryString,
                      ),
                    ));
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
