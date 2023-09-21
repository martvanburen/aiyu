import 'dart:convert';

import 'package:ai_yu/awsconfiguration.dart';
import 'package:ai_yu/core/result.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class _IAPFinalizerStep {
  final String title;
  final Future<VoidResult> Function() func;

  const _IAPFinalizerStep(this.title, this.func);
}

class IAPFinalizer {
  // Steps:
  late final List<_IAPFinalizerStep> _steps = [
    _IAPFinalizerStep(
      "Checking purchase status...",
      _checkPurchaseStatus,
    ),
    _IAPFinalizerStep(
      "Checking account...",
      _checkLoggedIn,
    ),
    _IAPFinalizerStep(
      "Validating purchase...",
      _validateAndConsume,
    ),
  ];

  // Initial variables:
  final PurchaseDetails purchaseDetails;
  IAPFinalizer(this.purchaseDetails);

  Future<VoidResult> run(
      {required void Function(String message) onFinalizationUpdate}) async {
    for (final step in _steps) {
      onFinalizationUpdate(step.title);
      final result = await step.func();
      if (!result.success) {
        return VoidResult.err(result.error!);
      }
    }
    return VoidResult.ok();
  }

  // ---------------------------------------------------------------------------

  Future<VoidResult> _checkPurchaseStatus() async {
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      return VoidResult.ok();
    } else {
      return VoidResult.err(
          "Purchase was not fully completed, so the transaction was not finalized. "
          "If your card was charged, it will be refunded automatically after 3 days.");
    }
  }

  Future<VoidResult> _checkLoggedIn() async {
    if ((await Amplify.Auth.fetchAuthSession()).isSignedIn) {
      return VoidResult.ok();
    } else {
      return VoidResult.err(
          "An internal error occured: an account should have been "
          "auto-generated for you before starting the in-app-purchase, but no "
          "log-in details were found. The transaction was not completed. If "
          "your card was charged, it will be refunded automatically after 3 days.");
    }
  }

  Future<VoidResult> _validateAndConsume() async {
    dynamic data;
    try {
      final cognitoPlugin =
          Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      final result = await cognitoPlugin.fetchAuthSession();
      final identityId = result.userPoolTokensResult.value.idToken.raw;

      final response = await Amplify.API.post(
        "/wallet/complete-purchase",
        body: HttpPayload.json({
          "source": purchaseDetails.verificationData.source,
          "productId": purchaseDetails.productID,
          "verificationData":
              purchaseDetails.verificationData.serverVerificationData,
        }),
        apiName: "aiyu-backend",
        headers: {
          "Authorization": identityId,
          "x-api-key": apikey,
        },
      ).response;
      data = json.decode(response.decodeBody());
    } on ApiException {
      return VoidResult.err(
          "An error occured while communicating with the server to verify your "
          "purchase. The transaction was not completed. If your card was charged, "
          "it will be refunded automatically after 3 days.");
    }

    try {
      if (data["status_code"] == 200) {
        return VoidResult.ok();
      } else {
        return VoidResult.err(
            "We could not verify your purchase. The transaction was not completed. "
            "If your card was charged, it will be refunded automatically after 3 days.");
      }
    } catch (e) {
      return VoidResult.err(
          "An error occured while communicating with the server to verify your "
          "purchase. The transaction was not completed. If your card was charged, "
          "it will be refunded automatically after 3 days.");
    }
  }
}
