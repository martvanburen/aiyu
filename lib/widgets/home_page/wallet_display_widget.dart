import 'package:ai_yu/data/state_models/wallet_model.dart';
import 'package:ai_yu/widgets/home_page/wallet_info_dialog.dart';
import 'package:ai_yu/widgets/shared/in_app_purchase_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletDisplayWidget extends StatefulWidget {
  const WalletDisplayWidget({Key? key}) : super(key: key);

  @override
  State<WalletDisplayWidget> createState() => _WalletDisplayWidgetState();
}

class _WalletDisplayWidgetState extends State<WalletDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WalletModel>(builder: (context, wallet, child) {
      return Card(
        margin: const EdgeInsets.only(top: 15.0),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Wallet Balance:",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    wallet.isLoading
                        ? Container(
                            width: 80,
                            margin: const EdgeInsets.symmetric(vertical: 24.0),
                            child: const LinearProgressIndicator(),
                          )
                        : Text("${wallet.centBalance.toStringAsFixed(1)}¢",
                            style: const TextStyle(fontSize: 36)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => showInAppPurchaseDialog(context),
                child: const Text("Add 50¢"),
              ),
              IconButton(
                onPressed: _showCostBreakdown,
                icon: const Icon(Icons.info),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showCostBreakdown() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const WalletInfoDialog(),
    );
  }
}
