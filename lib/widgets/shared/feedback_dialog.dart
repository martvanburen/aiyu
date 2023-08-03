import "dart:convert";

import 'package:ai_yu/awsconfiguration.dart';
import "package:ai_yu/utils/event_recorder.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _pageIndex = 0;
  final TextEditingController textController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  // Always check if mounted before setting state.
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<(bool, int?, String?)> _uploadFeedback(String text) async {
    if (text.isEmpty) {
      return (false, null, "Please enter feedback in text field.");
    }
    try {
      // If user is logged in, add the id token to the request.
      String? identityId;
      if ((await Amplify.Auth.fetchAuthSession()).isSignedIn) {
        final cognitoPlugin =
            Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
        final result = await cognitoPlugin.fetchAuthSession();
        identityId = result.userPoolTokensResult.value.idToken.raw;
      }

      // Submit feedback to API.
      final response = await Amplify.API.post(
        (identityId != null) ? "/stats/feedback-auth" : "/stats/feedback",
        body: HttpPayload.json({"text": text}),
        apiName: "aiyu-backend",
        headers: {
          if (identityId != null) "Authorization": identityId,
          "x-api-key": apikey
        },
      ).response;

      // Check for errors.
      final jsonResponse = json.decode(response.decodeBody());
      final statusCode = jsonResponse["status_code"] as int?;
      if (statusCode != 200) {
        return (false, statusCode, jsonResponse["error"] as String?);
      } else {
        return (true, null, null);
      }
    } on ApiException catch (e) {
      return (false, null, e.message);
    }
  }

  void _submit() async {
    setState(() {
      _isLoading = true;
    });
    final (success, errorCode, errorMessage) =
        await _uploadFeedback(textController.text);
    if (success) {
      EventRecorder.feedbackSubmit();
    } else {
      EventRecorder.errorSendingFeedback(code: errorCode);
    }
    setState(() {
      if (success) _pageIndex = 1;
      _error = errorMessage;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Submit Feedback",
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      content: IndexedStack(
        index: _pageIndex,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text("TODO: Add message."),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: "Feedback",
                  counterText: "",
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 10.0),
              _error != null
                  ? Text(
                      _error!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.red),
                    )
                  : Container(),
            ],
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Feedback was successfully submitted. Thank you!"),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        _pageIndex == 0
            ? TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : Container(),
        _isLoading
            ? const SizedBox(
                width: 15, height: 15, child: CircularProgressIndicator())
            : FilledButton(
                child: Text(_pageIndex == 0 ? "Submit" : "Close"),
                onPressed: () {
                  if (_pageIndex == 0) {
                    _submit();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
      ],
    );
  }
}
