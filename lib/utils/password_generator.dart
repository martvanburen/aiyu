import 'dart:math';

String generateCryptographicallySecurePassword() {
  return List.generate(30, (_) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()_+';
    return chars[Random.secure().nextInt(chars.length)];
  }).join();
}
