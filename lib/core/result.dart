// Generic object to be returned by functions, to mimic Rust's Result<T, Err>.
class Result<T> {
  final bool success;
  final T? data;
  final String? error;

  Result.ok(T this.data)
      : success = true,
        error = null;

  Result.err(String this.error)
      : success = false,
        data = null;

  VoidResult toVoidResult() {
    if (success) {
      return VoidResult.ok();
    } else {
      return VoidResult.err(error!);
    }
  }
}

class VoidResult extends Result<void> {
  VoidResult.ok() : super.ok(null);
  VoidResult.err(String error) : super.err(error);
}
