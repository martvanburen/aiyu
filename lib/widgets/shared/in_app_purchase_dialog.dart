import "package:ai_yu/data/state_models/wallet_model.dart";
import "package:ai_yu/utils/in_app_purchase_util.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class InAppPurchaseDialog extends StatefulWidget {
  const InAppPurchaseDialog({super.key});

  @override
  State<InAppPurchaseDialog> createState() => _InAppPurchaseDialogState();
}

class _InAppPurchaseDialogState extends State<InAppPurchaseDialog> {
  late final InAppPurchaseUtil _iapUtil;

  PurchaseStatus _purchaseStatus = PurchaseStatus.finalizing;
  String? _message;

  @override
  void initState() {
    super.initState();
    _iapUtil = InAppPurchaseUtil(onUpdate: _onUpdate);
    _iapUtil.initialize50cTopUp();
  }

  @override
  void dispose() {
    _iapUtil.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: AlertDialog(
          title: const Text("Wallet Top-Up"),
          content: _buildDialogContent(),
          actions: [_buildDialogAction()],
        ));
  }

  Widget _buildDialogContent() {
    switch (_purchaseStatus) {
      case PurchaseStatus.initializing:
      case PurchaseStatus.finalizing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(_message ?? "Initializing..."),
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
          ],
        );
      case PurchaseStatus.error:
        return Text(_message ?? "Unknown error occurred.");
      case PurchaseStatus.complete:
        return const Text(
            "Purchase completed successfully, and wallet balance has been updated. Thank you!");
    }
  }

  Widget _buildDialogAction() {
    String? buttonText;
    switch (_purchaseStatus) {
      case PurchaseStatus.initializing:
      case PurchaseStatus.finalizing:
        buttonText = "Cancel";
        break;
      case PurchaseStatus.error:
      case PurchaseStatus.complete:
        buttonText = "Close";
        break;
    }
    return TextButton(
      onPressed: () => Navigator.of(context).maybePop(),
      child: Text(buttonText),
    );
  }

  Future<bool> _onWillPop() async {
    if (_purchaseStatus == PurchaseStatus.finalizing) {
      return (await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Confirmation"),
                content: const Text(
                    "Purchase is finalizing, are you sure you wish to cancel? "
                    "Any unfinished purchase will be automatically refunded after 3 days."),
                actions: [
                  TextButton(
                    child: const Text("No"),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: const Text("Yes"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          )) ??
          false;
    } else {
      return true;
    }
  }

  void _onUpdate(PurchaseStatus status, String? message) {
    setState(() {
      _purchaseStatus = status;
      _message = message;
    });
    if (status == PurchaseStatus.complete) {
      Provider.of<WalletModel>(context, listen: false).refresh();
    }
  }
}

void showInAppPurchaseDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const InAppPurchaseDialog();
    },
  );
}
