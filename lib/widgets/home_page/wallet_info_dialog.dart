import "package:ai_yu/data_structures/global_state/auth_model.dart";
import 'package:ai_yu/widgets/shared/authentication_dialog.dart';
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
            Consumer<AuthModel>(builder: (context, auth, child) {
              return TextButton(
                onPressed: () {
                  if (auth.isSignedIn) {
                    auth.signOut();
                  } else {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        // Since user needs to switch to email and back for
                        // their verification code, prevent accidental dismissal
                        // of dialog.
                        barrierDismissible: false,
                        builder: (context) => const AuthenticationDialog(
                            mode: AuthenticationMode.restoreWallet));
                  }
                },
                child: Text(auth.isSignedIn ? "Logout" : "Restore Wallet"),
              );
            }),
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
