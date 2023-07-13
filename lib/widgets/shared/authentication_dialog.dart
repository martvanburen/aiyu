import "package:ai_yu/utils/password_generator.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";

enum AuthenticationMode { restoreWallet, newSignup }

class AuthenticationDialog extends StatefulWidget {
  final AuthenticationMode mode;

  const AuthenticationDialog({super.key, required this.mode});

  @override
  State<AuthenticationDialog> createState() => _AuthenticationDialogState();
}

class _AuthenticationDialogState extends State<AuthenticationDialog> {
  int _pageIndex = 0;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  String _submissionEmail = "";

  bool _isLoading = false;
  String _emailError = "";
  String _codeError = "";

  // Always check if mounted before setting state.
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _startResetPasswordFlow() async {
    setState(() {
      _isLoading = true;
    });

    _submissionEmail = emailController.text;
    try {
      await Amplify.Auth.resetPassword(
        username: _submissionEmail,
      );
      setState(() {
        _pageIndex = 1;
      });
    } on AuthException catch (e) {
      setState(() {
        _emailError = e.message;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _completeResetPasswordFlowAndLogin() async {
    setState(() {
      _isLoading = true;
    });

    final String randomPassword = generateCryptographicallySecurePassword();
    try {
      ResetPasswordResult resetPasswordResult =
          await Amplify.Auth.confirmResetPassword(
        username: _submissionEmail,
        newPassword: randomPassword,
        confirmationCode: codeController.text,
      );

      if (resetPasswordResult.nextStep.updateStep ==
          AuthResetPasswordStep.done) {
        SignInResult signInResult = await Amplify.Auth.signIn(
          username: _submissionEmail,
          password: randomPassword,
        );
        if (signInResult.isSignedIn) {
          return true;
        } else {
          setState(() {
            _codeError = "Unable to sign in.";
          });
        }
      } else {
        setState(() {
          _codeError = "Something went wrong. Please try again.";
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _codeError = e.message;
      });
    }

    setState(() {
      _isLoading = false;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Restore Wallet",
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      content: IndexedStack(
        index: _pageIndex,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                  "To restore a previous wallet, enter your email address:"),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  counterText: "",
                ),
                maxLength: 200,
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10.0),
              _emailError != ""
                  ? Text(
                      _emailError,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.red),
                    )
                  : Container(),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                  "A verification code was sent to your email, please enter it here:"),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: "Verification Code",
                  counterText: "",
                ),
                maxLength: 200,
                maxLines: 1,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10.0),
              _codeError != ""
                  ? Text(
                      _codeError,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.red),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        _isLoading
            ? const SizedBox(
                width: 15, height: 15, child: CircularProgressIndicator())
            : FilledButton(
                child: Text(_pageIndex == 0 ? "Next" : "Complete"),
                onPressed: () {
                  if (_pageIndex == 0) {
                    _startResetPasswordFlow();
                  } else {
                    _completeResetPasswordFlowAndLogin().then((successful) {
                      if (successful) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Wallet successfully restored!")));
                        Navigator.of(context).pop();
                      }
                    });
                  }
                },
              ),
      ],
    );
  }
}
