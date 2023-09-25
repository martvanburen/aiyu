import 'package:ai_yu/data/state_models/wallet_model.dart';
import 'package:ai_yu/widgets/shared/in_app_purchase_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MiniWalletWidget extends StatelessWidget {
  const MiniWalletWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletModel>(
      builder: (context, wallet, child) {
        return wallet.centBalance != null
            ? TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                onPressed: () => showInAppPurchaseDialog(context),
                child: Text("${wallet.centBalance!.toStringAsFixed(0)}¢"),
              )
            : const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: SizedBox(
                  width: 30,
                  height: 5,
                  child: LinearProgressIndicator(),
                ),
              );
      },
    );
  }
}
