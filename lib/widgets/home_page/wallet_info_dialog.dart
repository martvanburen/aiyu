import "package:ai_yu/pages/login_page.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:ai_yu/data_structures/global_state/deeplinks_model.dart";

class WalletInfoDialog extends StatelessWidget {
  const WalletInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeeplinksModel>(
      builder: (context, deeplinks, child) {
        return AlertDialog(
          title: const Text("Wallet Information"),
          content: const SingleChildScrollView(
            child: Text(
              """
TODO(Mart): Add wallet information here.
""",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ));
              },
              child: const Text("Restore Purchases"),
            ),
            FilledButton(
              child: const Text("Close"),
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
