import "dart:async";

import "package:ai_yu/amplifyconfiguration.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";

class AuthModel extends ChangeNotifier {
  late final Future<bool> _initialization;
  late final StreamSubscription<AuthHubEvent> _authEventSubscription;

  AuthModel() {
    _initialization = _configureAmplify();
    _authEventSubscription = Amplify.Hub.listen(HubChannel.Auth, _onAuthEvent);
  }

  Future<bool> _configureAmplify() async {
    try {
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.configure(amplifyconfig);
      notifyListeners();
      return true;
    } on Exception {
      safePrint("ERROR: Failed to initialize Amplify.");
    }
    return false;
  }

  void _onAuthEvent(AuthHubEvent event) {
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    if (await _initialization == false) return false;
    final auth = await Amplify.Auth.fetchAuthSession();
    return auth.isSignedIn;
  }

  @override
  void dispose() {
    _authEventSubscription.cancel();
    super.dispose();
  }
}
