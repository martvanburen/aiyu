import 'dart:convert';

import 'package:ai_yu/amplifyconfiguration.dart';
import 'package:ai_yu/data/state_models/aws_model.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import "package:flutter/material.dart";

class WalletModel extends ChangeNotifier {
  late final AWSModel? _aws;
  bool _disposed = false;

  late final Future<void> _initialization;
  Future<void> get initialization => _initialization;

  // Measured in 100ths of a cent.
  late int _microcentBalance;

  int get microcentBalance => _microcentBalance;
  double get centBalance => _microcentBalance / 100.0;
  double get dollarBalance => _microcentBalance / 10000.0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WalletModel(this._aws, WalletModel? previousWallet) {
    _microcentBalance = previousWallet?._microcentBalance ?? 0;
    _initialization = _fetchWalletBalance();
  }

  // TMP: For testing.
  String regionText = "";

  // Since this model is a proxy provider, it will be recreated whenever the
  // AWSModel changes, so we need to protect against calling notifyListeners()
  // on a disposed object.
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  Future<void> _fetchWalletBalance() async {
    if (_aws == null) return;

    _isLoading = true;
    notifyListeners();

    if (!_aws!.isSignedIn) {
      // If not logged in, balance is 0.
      _microcentBalance = 0;
    } else {
      // Otherwise, fetch from API.
      try {
        final cognitoPlugin =
            Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
        final result = await cognitoPlugin.fetchAuthSession();
        final identityId = result.userPoolTokensResult.value.idToken.raw;

        final response = await Amplify.API.get(
          "/wallet/get-balance",
          apiName: "aiyu-backend",
          headers: {
            "Authorization": identityId,
            "x-api-key": apikey,
          },
        ).response;

        final jsonResponse = json.decode(response.decodeBody());
        _microcentBalance = jsonResponse["balance_hundredthcent"];

        // Also fetch region.
        final region = await Amplify.API
            .get(
              "/health",
              apiName: "aiyu-backend",
            )
            .response;
        regionText = region.decodeBody();
      } catch (e) {
        safePrint("Wallet fetch failed: '$e'. ");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> add50Cent() async {
    final result = await _aws?.initializeTemporaryAccount() ?? false;
    if (result == true) {
      safePrint("Signed in as temporary account.");
    } else {
      safePrint("Failed to sign in as temporary account.");
    }
    return result;
  }

  void setBalance({required int microcents}) {
    _microcentBalance = microcents;
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
    _disposed = true;
    super.dispose();
  }
}
