import "package:ai_yu/data_structures/global_state/auth_model.dart";
import "package:flutter/material.dart";

class WalletModel extends ChangeNotifier {
  late final AuthModel? _auth;

  // Measured in 100ths of a cent.
  late int _microcentBalance;

  int get microcentBalance => _microcentBalance;
  double get centBalance => _microcentBalance / 100.0;
  double get dollarBalance => _microcentBalance / 10000.0;

  WalletModel(this._auth, WalletModel? previousWallet) {
    _microcentBalance = previousWallet?._microcentBalance ?? 0;
    _fetchWalletBalance();
  }

  void _fetchWalletBalance() async {
    await _auth?.initialization;
    if (_auth?.isSignedIn ?? false) {
      _microcentBalance = 100000;
      notifyListeners();
    }
  }

  void add50Cent() {
    _microcentBalance += 5000;
    notifyListeners();
  }

  int _calculateQueryCost() {
    return 2;
  }

  double calculateQueryCostInCents() {
    return _calculateQueryCost() / 100.0;
  }
}
