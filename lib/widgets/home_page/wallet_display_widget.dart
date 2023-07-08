import 'package:ai_yu/data_structures/global_state/wallet_model.dart';
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
                    Text("${wallet.centBalance.toStringAsFixed(2)}¢",
                        style: const TextStyle(fontSize: 36)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => wallet.add50Cent(),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cost Breakdown"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("GPT-4 query cost: \$0.03"),
              Text("AWS Polly cost: \$0.04"),
              Text("App charge: 50%"),
            ],
          ),
          actions: [
            TextButton(
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
