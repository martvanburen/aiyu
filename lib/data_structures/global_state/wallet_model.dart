import "package:flutter/material.dart";

class WalletModel extends ChangeNotifier {
  // Measured in 100ths of a cent.
  int _microcentBalance = 0;

  int get microcentBalance => _microcentBalance;
  double get centBalance => _microcentBalance / 100.0;
  double get dollarBalance => _microcentBalance / 10000.0;

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
