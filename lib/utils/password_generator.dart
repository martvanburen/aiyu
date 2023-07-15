import 'dart:math';

String generateUsername() {
  final suffix = List.generate(10, (_) {
    const chars = '0123456789abcdef';
    return chars[Random.secure().nextInt(chars.length)];
  }).join();
  return "auto-${DateTime.now().millisecondsSinceEpoch}-$suffix";
}

String generateCryptographicallySecurePassword() {
  return List.generate(30, (_) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()_+';
    return chars[Random.secure().nextInt(chars.length)];
  }).join();
}
