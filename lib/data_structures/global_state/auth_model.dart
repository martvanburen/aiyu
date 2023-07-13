import "dart:async";

import "package:ai_yu/amplifyconfiguration.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";

class AuthModel extends ChangeNotifier {
  late final StreamSubscription<AuthHubEvent> _authEventSubscription;

  late final Future<bool> _initialization;
  Future<bool> get initialization => _initialization;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  AuthModel() {
    _initialization = _configureAmplify();
    _authEventSubscription = Amplify.Hub.listen(HubChannel.Auth, _onAuthEvent);
  }

  Future<bool> _configureAmplify() async {
    try {
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.configure(amplifyconfig);
      _isSignedIn = (await Amplify.Auth.fetchAuthSession()).isSignedIn;
      notifyListeners();
      return true;
    } on Exception {
      safePrint("ERROR: Failed to initialize Amplify.");
    }
    return false;
  }

  void _onAuthEvent(AuthHubEvent event) async {
    _isSignedIn = (await Amplify.Auth.fetchAuthSession()).isSignedIn;
    notifyListeners();
  }

  void signOut() async {
    Amplify.Auth.signOut();
  }

  @override
  void dispose() {
    _authEventSubscription.cancel();
    super.dispose();
  }
}
