import 'package:ai_yu/data/state_models/aws_model.dart';
import 'package:ai_yu/data/state_models/wallet_model.dart';
import 'package:ai_yu/widgets/shared/authentication_dialog.dart';
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class WalletInfoDialog extends StatelessWidget {
  const WalletInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletModel>(
      builder: (context, wallet, child) {
        return AlertDialog(
          title: const Text("Wallet Information"),
          content: const SingleChildScrollView(
            child: Text(
              "TODO(Mart): Add wallet information here.",
            ),
          ),
          actions: <Widget>[
            Consumer<AWSModel>(
              builder: (context, aws, child) {
                String text = "";
                Function action = () {};

                if (!aws.isSignedIn) {
                  text = "Restore Account";
                  action = () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        // Since user needs to switch to email and back for
                        // their verification code, prevent accidental dismissal
                        // of dialog.
                        barrierDismissible: false,
                        builder: (context) => const AuthenticationDialog(
                            mode: AuthenticationMode.restoreAccount));
                  };
                } else if (aws.isTemporaryAccount) {
                  text = "Backup Account";
                  action = () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        // Since user needs to switch to email and back for
                        // their verification code, prevent accidental dismissal
                        // of dialog.
                        barrierDismissible: false,
                        builder: (context) => const AuthenticationDialog(
                            mode: AuthenticationMode.addEmail));
                  };
                } else {
                  text = "Sign Out";
                  action = () {
                    aws.signOut();
                  };
                }

                return TextButton(
                  onPressed: () => action(),
                  child: Text(text),
                );
              },
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
