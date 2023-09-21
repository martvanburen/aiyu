enum PurchaseStatus { initializing, finalizing, error, complete }

typedef UpdateHandler = void Function(PurchaseStatus status, String? message);

class InAppPurchaseUtil {
  void purchase50cTopUp({required UpdateHandler updateHandler}) {}
}
