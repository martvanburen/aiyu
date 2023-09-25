import 'package:ai_yu/core/result.dart';
import 'package:ai_yu/data/state_models/aws_model.dart';
import 'package:ai_yu/utils/event_recorder.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class _IAPInitializerStep {
  final String title;
  final Future<VoidResult> Function() func;

  const _IAPInitializerStep(this.title, this.func);
}

class IAPInitializer {
  // Steps:
  late final List<_IAPInitializerStep> _steps = [
    _IAPInitializerStep(
      "Checking connection...",
      _checkIAPConnection,
    ),
    _IAPInitializerStep(
      "Creating temporary AiYu account...",
      _createTemporaryUserIfNecessary,
    ),
    _IAPInitializerStep(
      "Loading in-app-purchase details...",
      _loadProductDetails,
    ),
    _IAPInitializerStep(
      "Requesting in-app-purchase...",
      _startPurchase,
    ),
  ];

  // Initial variables:
  final String productId;
  IAPInitializer(this.productId);

  // Intermediate variables:
  ProductDetails? _productDetails;

  Future<VoidResult> run(
      {required void Function(String message) onInitializationUpdate}) async {
    for (final step in _steps) {
      onInitializationUpdate(step.title);
      final result = await step.func();
      if (!result.success) {
        return VoidResult.err(result.error!);
      }
    }
    return VoidResult.ok();
  }

  // ---------------------------------------------------------------------------

  Future<VoidResult> _checkIAPConnection() async {
    if (await InAppPurchase.instance.isAvailable()) {
      return VoidResult.ok();
    } else {
      EventRecorder.errorIAPInitializationCheckConnection();
      return VoidResult.err(
          "In-app-purchases are not available on this device.");
    }
  }

  Future<VoidResult> _createTemporaryUserIfNecessary() async {
    if ((await Amplify.Auth.fetchAuthSession()).isSignedIn) {
      // Already signed in.
      return VoidResult.ok();
    } else {
      final success = await AWSModel.initializeTemporaryAccount();
      if (success) {
        return VoidResult.ok();
      } else {
        EventRecorder.errorIAPInitializationCreateTemporaryAccount();
        return VoidResult.err(
            "Failed to create AiYu account, please check your internet "
            "connection and try again. If the problem persists, please contact "
            "me at aiyu@eigenvalue.tools :(");
      }
    }
  }

  Future<VoidResult> _loadProductDetails() async {
    final productDetailsSearch =
        await InAppPurchase.instance.queryProductDetails({productId});
    if (productDetailsSearch.notFoundIDs.isNotEmpty ||
        productDetailsSearch.productDetails.isEmpty) {
      EventRecorder.errorIAPInitializationLoadProduct();
      return VoidResult.err(
          "Unfortunately, it seems this in-app-purchase is currently not "
          "available in your region. I'm trying to support every region I can, "
          "so please check back later, or contact me at aiyu@eigenvalue.tools.");
    } else {
      _productDetails = productDetailsSearch.productDetails.first;
      return VoidResult.ok();
    }
  }

  Future<VoidResult> _startPurchase() async {
    final purchaseParam = PurchaseParam(productDetails: _productDetails!);
    await InAppPurchase.instance
        .buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
    return VoidResult.ok();
  }
}
