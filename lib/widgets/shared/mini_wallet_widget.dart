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
        return TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: () => showInAppPurchaseDialog(context),
          child: Text("${wallet.centBalance.toStringAsFixed(0)}¢"),
        );
      },
    );
  }
}
