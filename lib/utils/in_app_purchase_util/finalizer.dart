import 'package:ai_yu/core/result.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPFinalizer {
  final PurchaseDetails purchaseDetails;
  IAPFinalizer(this.purchaseDetails);

  Future<VoidResult> run(
      {required void Function(String message) onFinalizationUpdate}) async {
    return VoidResult.ok();
  }
}
