import "dart:convert";

import 'package:ai_yu/awsconfiguration.dart';
import "package:ai_yu/data/state_models/aws_model.dart";
import "package:ai_yu/utils/event_recorder.dart";
import "package:ai_yu/utils/password_generator.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

enum AuthenticationMode { restoreAccount, addEmail }

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

  // Fetched from server using email.
  String? _username;

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

  Future<(bool, String)> _getUsernameFromEmail(String email) async {
    try {
      final response = await Amplify.API.post(
        "/auth/recover-username",
        body: HttpPayload.json({"email": email}),
        apiName: "aiyu-backend",
        headers: {"x-api-key": apikey},
      ).response;
      final jsonResponse = json.decode(response.decodeBody());
      if ((jsonResponse["error"] as String?) != null) {
        return (false, jsonResponse["error"] as String);
      } else if ((jsonResponse["username"] as String?) != null) {
        return (true, jsonResponse["username"] as String);
      } else {
        return (false, "Error fetching user.");
      }
    } on ApiException catch (e) {
      return (false, e.message);
    }
  }

  void _startFlow() async {
    setState(() {
      _isLoading = true;
    });
    final (success, errorMessage) =
        (widget.mode == AuthenticationMode.restoreAccount)
            ? await _startResetPassword()
            : await _startAddEmail();
    setState(() {
      if (success) _pageIndex = 1;
      _emailError = errorMessage;
      _isLoading = false;
    });
  }

  Future<bool> _completeFlow() async {
    setState(() {
      _isLoading = true;
    });
    final (success, errorMessage) =
        (widget.mode == AuthenticationMode.restoreAccount)
            ? await _completeResetPasswordAndLogin()
            : await _completeAddEmail();
    setState(() {
      _codeError = errorMessage;
      _isLoading = false;
    });
    return success;
  }

  Future<(bool, String)> _startResetPassword() async {
    EventRecorder.authRecoverUsernameStart();

    // Fetch username from email.
    _username = null;
    final (success, result) = await _getUsernameFromEmail(emailController.text);
    if (success) {
      _username = result;
    } else {
      return (false, result);
    }

    // Start reset password flow.
    try {
      await Amplify.Auth.resetPassword(
        username: _username!,
      );
      return (true, "");
    } on AuthException catch (e) {
      return (false, e.message);
    }
  }

  Future<(bool, String)> _completeResetPasswordAndLogin() async {
    final String randomPassword = generateCryptographicallySecurePassword();
    try {
      ResetPasswordResult resetPasswordResult =
          await Amplify.Auth.confirmResetPassword(
        username: _username!,
        newPassword: randomPassword,
        confirmationCode: codeController.text,
      );

      if (resetPasswordResult.nextStep.updateStep ==
          AuthResetPasswordStep.done) {
        SignInResult signInResult = await Amplify.Auth.signIn(
          username: _username!,
          password: randomPassword,
        );
        if (signInResult.isSignedIn) {
          EventRecorder.authRecoverUsernameComplete();
          return (true, "");
        } else {
          return (false, "Unable to sign in.");
        }
      } else {
        return (false, "Something went wrong. Please try again.");
      }
    } on AuthException catch (e) {
      return (false, e.message);
    }
  }

  Future<(bool, String)> _startAddEmail() async {
    EventRecorder.authAddEmailStart();

    // Check email is not already registered.
    final (emailAlreadyRegistered, _) =
        await _getUsernameFromEmail(emailController.text);
    if (emailAlreadyRegistered) {
      return (false, "Email is already registered to another account.");
    }

    try {
      await Amplify.Auth.updateUserAttribute(
        userAttributeKey: AuthUserAttributeKey.email,
        value: emailController.text,
      );
      return (true, "");
    } on AuthException catch (e) {
      return (false, e.message);
    }
  }

  Future<(bool, String)> _completeAddEmail() async {
    try {
      await Amplify.Auth.confirmUserAttribute(
        userAttributeKey: AuthUserAttributeKey.email,
        confirmationCode: codeController.text,
      );
      // Need to manually trigger onAuthEvent to recalculate isTemporaryAccount,
      // since adding email does not cause a sign-in event.
      //
      // ignore: use_build_context_synchronously
      Provider.of<AWSModel>(context, listen: false).onAuthEvent(null);
      EventRecorder.authAddEmailComplete();
      return (true, "");
    } on AuthException catch (e) {
      return (false, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _getTitle(),
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      content: IndexedStack(
        index: _pageIndex,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_getWelcomeMessage()),
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
                    _startFlow();
                  } else {
                    _completeFlow().then((successful) {
                      if (successful) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getCompletionMessage())));
                        Navigator.of(context).pop();
                      }
                    });
                  }
                },
              ),
      ],
    );
  }

  String _getTitle() {
    if (widget.mode == AuthenticationMode.restoreAccount) {
      return "Restore Account";
    } else {
      return "Backup Account";
    }
  }

  String _getWelcomeMessage() {
    if (widget.mode == AuthenticationMode.restoreAccount) {
      return "To restore a previous account, enter your email address:";
    } else {
      return "Add your email address to easily restore your wallet in the future:";
    }
  }

  String _getCompletionMessage() {
    if (widget.mode == AuthenticationMode.restoreAccount) {
      return "Account restored!";
    } else {
      return "Email verified!";
    }
  }
}
