import "package:ai_yu/widgets/shared/authentication_dialog.dart";
import "package:flutter/material.dart";

class TemporaryAccountWarningDialog extends StatefulWidget {
  const TemporaryAccountWarningDialog({super.key});

  @override
  State<TemporaryAccountWarningDialog> createState() =>
      _TemporaryAccountWarningDialogState();
}

class _TemporaryAccountWarningDialogState
    extends State<TemporaryAccountWarningDialog> {
  bool _secondWarningShown = false;

  void _showSecondWarning() {
    setState(() {
      _secondWarningShown = true;
    });
  }

  void _resetWarning() {
    setState(() {
      _secondWarningShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showSecondWarning();
        return false;
      },
      child: AlertDialog(
        title: const Text("Back-Up Your Account"),
        content: Text(
          _secondWarningShown
              ? "Are you sure you want to continue without backing up your account? We will not be able to recover your account for you."
              : "You are using a temporary, auto-generated account. If you lose access to this device or delete this app, you will not be able to recover your wallet. Would you like to back-up your account by adding your email?",
        ),
        actions: <Widget>[
          if (_secondWarningShown)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Yes, I'm Sure"),
            ),
          TextButton(
            onPressed: () {
              if (_secondWarningShown) {
                _resetWarning();
              } else {
                _showSecondWarning();
              }
            },
            child: Text(_secondWarningShown ? "Go Back" : "No"),
          ),
          if (!_secondWarningShown)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showBackupAccountDialog(context);
              },
              child: const Text("Yes"),
            ),
        ],
      ),
    );
  }
}

void showTemporaryAccountWarningDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const TemporaryAccountWarningDialog();
    },
  );
}
