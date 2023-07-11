import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackOrCloseButton extends StatelessWidget {
  const BackOrCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => SystemNavigator.pop(),
      );
    }
  }
}
