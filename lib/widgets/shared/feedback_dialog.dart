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
    if (text == "HEALTH") {
      // For debugging: easter egg to check API health / region.
      final region = await Amplify.API
          .get(
            "/health",
            apiName: "aiyu-backend",
          )
          .response;
      return (false, null, region.decodeBody());
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
    } else if (errorCode != null) {
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
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                    "I'm just an independant developer, working on this app as a hobby project "
                    "because I spend so much of my life in Anki. There will certainly be bugs, "
                    "but I'll try my best to listen to your feedback and fix what I can. I hope "
                    "this app useful to you, please let me know whatever suggestions you have "
                    "to improve it."),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: "Feedback Input",
                    counterText: "",
                  ),
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 10.0),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 10.0),
                ],
                const Text(
                    "Note: Your user id will be sent along with the feedback."),
              ],
            ),
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
