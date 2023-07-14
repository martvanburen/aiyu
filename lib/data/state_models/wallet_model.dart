import 'dart:async';

import 'package:ai_yu/data/aws_models/Wallet.dart';
import 'package:ai_yu/data/state_models/aws_model.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import "package:flutter/material.dart";

class WalletModel extends ChangeNotifier {
  late final AWSModel? _aws;
  StreamSubscription<QuerySnapshot<Wallet>>? _walletSubscription;

  // Measured in 100ths of a cent.
  late int _microcentBalance;

  int get microcentBalance => _microcentBalance;
  double get centBalance => _microcentBalance / 100.0;
  double get dollarBalance => _microcentBalance / 10000.0;

  WalletModel(this._aws, WalletModel? previousWallet) {
    _microcentBalance = previousWallet?._microcentBalance ?? 0;
    _configureWalletSubscription();
  }

  void _configureWalletSubscription() async {
    if (_aws == null) return;

    _walletSubscription = Amplify.DataStore.observeQuery(
      Wallet.classType,
      where: Wallet.IDENTITY_ID.eq(await _aws!.getUserSub()),
    ).listen((QuerySnapshot<Wallet> snapshot) {
      _microcentBalance = snapshot.items.first.balance_microcents;
      notifyListeners();
    });
  }

  void add50Cent() async {
    if (_aws == null) return;

    final userSub = await _aws!.getUserSub();

    final oldWallet = (await Amplify.DataStore.query(
          Wallet.classType,
          where: Wallet.IDENTITY_ID.eq(userSub),
        ))
            .firstOrNull ??
        Wallet(balance_microcents: 0, identity_id: userSub);

    final newWallet = oldWallet.copyWith(
        balance_microcents: oldWallet.balance_microcents + 5000);

    await Amplify.DataStore.save(newWallet);

    notifyListeners();
  }

  int _calculateQueryCost() {
    return 2;
  }

  double calculateQueryCostInCents() {
    return _calculateQueryCost() / 100.0;
  }

  @override
  void dispose() {
    _walletSubscription?.cancel();
    super.dispose();
  }
}
