import 'dart:async';

import 'package:ai_yu/utils/in_app_purchase_util/finalizer.dart';
import 'package:ai_yu/utils/in_app_purchase_util/initializer.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum PurchaseStatus { initializing, finalizing, error, complete }

typedef UpdateHandler = void Function(PurchaseStatus status, String? message);
typedef CompletionHandler = void Function();

class InAppPurchaseUtil {
  // Public:
  // ---------------------------------------------------------------------------

  final UpdateHandler _onUpdate;
  InAppPurchaseUtil({required void Function(PurchaseStatus, String?) onUpdate})
      : _onUpdate = onUpdate {
    _startListeningForPurchaseCompletions();
  }

  // Must be called by users of this util on widget disposal.
  Future<void> dispose() async {
    _purchaseCompletionSubscription.cancel();
  }

  void initialize50cTopUp() {
    _initializePurchase("wallet_add_50c");
  }

  // Private:
  // ---------------------------------------------------------------------------

  late StreamSubscription<List<PurchaseDetails>>
      _purchaseCompletionSubscription;

  // When user has made a purchase, we should automatically call the
  // finalization code.
  void _startListeningForPurchaseCompletions() {
    _purchaseCompletionSubscription =
        InAppPurchase.instance.purchaseStream.listen((purchases) {
      _finalizePurchase(purchases);
    }, onDone: () {
      _purchaseCompletionSubscription.cancel();
    }, onError: (error) {
      _onUpdate(PurchaseStatus.error, error.toString());
    });
  }

  Future<void> _initializePurchase(String productId) async {
    final result = await IAPInitializer(productId).run(
      onInitializationUpdate: (message) {
        _onUpdate(PurchaseStatus.initializing, message);
      },
    );
    if (result.success) {
      _onUpdate(PurchaseStatus.finalizing, "Awaiting purchase completion...");
    } else {
      _onUpdate(PurchaseStatus.error, result.error);
    }
  }

  Future<void> _finalizePurchase(List<PurchaseDetails> purchaseDetails) async {
    List<String> finalizationErrors = [];
    for (final purchaseDetail in purchaseDetails) {
      final result = await IAPFinalizer(purchaseDetail).run(
        onFinalizationUpdate: (message) {
          _onUpdate(PurchaseStatus.finalizing, message);
        },
      );
      if (!result.success) {
        finalizationErrors.add(result.error!);
      }
    }
    if (finalizationErrors.isEmpty) {
      _onUpdate(PurchaseStatus.complete, null);
    } else {
      _onUpdate(PurchaseStatus.error, finalizationErrors.join("\n"));
    }
  }
}
