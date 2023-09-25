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
                "Since this app is based on GPT, it costs some small amount in "
                "server fees per request. I'm not trying to make money with this "
                "app, so the wallet balance is just required to cover those "
                "server costs + a small margin. Costs are really low, so \$1 "
                "should probably last for a month of average usage or so."),
          ),
          actions: <Widget>[
            Consumer<AWSModel>(
              builder: (context, aws, child) {
                String? text;
                void Function()? action;

                if (aws.isSignedIn == false) {
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
                } else if (aws.isTemporaryAccount == true) {
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
                } else if (aws.isSignedIn == true) {
                  text = "Sign Out";
                  action = () {
                    AWSModel.signOut();
                  };
                } else {
                  // Still loading log-in state.
                  text = "";
                  action = null;
                }

                return TextButton(
                  onPressed: action,
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
