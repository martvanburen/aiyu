import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletDisplayWidget extends StatefulWidget {
  const WalletDisplayWidget({Key? key}) : super(key: key);

  @override
  State<WalletDisplayWidget> createState() => _WalletDisplayWidgetState();
}

class _WalletDisplayWidgetState extends State<WalletDisplayWidget> {
  double walletValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Wallet Value: ${formatCurrency.format(walletValue)}'),
          ElevatedButton(
            onPressed: () {
              setState(() {
                walletValue += 0.5; // Increment wallet value by 50 cents
              });
            },
            child: const Text('Add 50 cents.'),
          ),
        ],
      ),
    );
  }
}
